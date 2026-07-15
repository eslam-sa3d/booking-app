import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/models.dart';
import '../../repositories/booking_repository.dart';

class FirebaseBookingRepository implements BookingRepository {
  FirebaseBookingRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _bookings => _db.collection('bookings');
  CollectionReference<Map<String, dynamic>> get _sessions => _db.collection('sessions');

  @override
  Future<List<Booking>> getBookingsForUser(String userId) async {
    final snap = await _bookings.where('userId', isEqualTo: userId).get();
    final bookings = snap.docs.map((d) => Booking.fromMap(d.data())).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bookings;
  }

  /// Creates the booking doc client-side (status is a placeholder) then
  /// waits for the `onBookingCreate` Cloud Function to finalize the real
  /// status/session counts inside its transaction — same
  /// create-then-confirm pattern as [FirebaseAuthRepository] waiting on
  /// `onUserCreate`.
  Future<Booking> _createAndAwaitFinalization({
    required String userId,
    required String sessionId,
    required String participantId,
    required String participantName,
    String? recurrenceGroupId,
  }) async {
    final ref = _bookings.doc();
    final booking = Booking(
      id: ref.id,
      userId: userId,
      sessionId: sessionId,
      participantId: participantId,
      participantName: participantName,
      createdAt: DateTime.now(),
      isRecurring: recurrenceGroupId != null,
      recurrenceGroupId: recurrenceGroupId,
    );
    // 'pending' is a sentinel the client uses to detect once
    // onBookingCreate has run and overwritten it with the real
    // confirmed/waitlisted status — it's never a value the UI renders.
    await ref.set(booking.toMap()..['status'] = 'pending');

    for (var attempt = 0; attempt < 20; attempt++) {
      final snap = await ref.get();
      final status = snap.data()?['status'] as String?;
      if (status != null && status != 'pending') {
        return Booking.fromMap(snap.data()!);
      }
      await Future.delayed(const Duration(milliseconds: 250));
    }
    throw Exception('Booking confirmation is taking longer than expected. Check My Bookings shortly.');
  }

  @override
  Future<List<BookingResult>> createBooking({
    required String userId,
    required String sessionId,
    required String participantId,
    required String participantName,
    int recurringWeeks = 1,
  }) async {
    final results = <BookingResult>[];
    final recurrenceGroupId = recurringWeeks > 1 ? _bookings.doc().id : null;
    var currentSessionId = sessionId;

    for (var week = 0; week < recurringWeeks; week++) {
      final sessionSnap = await _sessions.doc(currentSessionId).get();
      if (!sessionSnap.exists) break;
      final session = SwimSession.fromMap(sessionSnap.data()!);

      final booking = await _createAndAwaitFinalization(
        userId: userId,
        sessionId: currentSessionId,
        participantId: participantId,
        participantName: participantName,
        recurrenceGroupId: recurrenceGroupId,
      );
      results.add(BookingResult(booking: booking, joinedWaitlist: booking.status == BookingStatus.waitlisted));

      if (week < recurringWeeks - 1) {
        final nextWeekDate = session.date.add(const Duration(days: 7));
        final nextSnap = await _sessions
            .where('classId', isEqualTo: session.classId)
            .where('startMinutes', isEqualTo: session.startMinutes)
            .where('date', isEqualTo: Timestamp.fromDate(DateTime(nextWeekDate.year, nextWeekDate.month, nextWeekDate.day)))
            .limit(1)
            .get();
        if (nextSnap.docs.isEmpty) break;
        currentSessionId = nextSnap.docs.first.id;
      }
    }
    return results;
  }

  /// Throws [CancellationNotAllowedException] if [bookingId]'s session
  /// starts within the 24h free-cancellation window.
  Future<void> _enforceCancellationPolicy(String bookingId) async {
    final bookingSnap = await _bookings.doc(bookingId).get();
    if (!bookingSnap.exists) return;
    final booking = Booking.fromMap(bookingSnap.data()!);
    final sessionSnap = await _sessions.doc(booking.sessionId).get();
    if (!sessionSnap.exists) return;
    final session = SwimSession.fromMap(sessionSnap.data()!);
    if (session.startDateTime.difference(DateTime.now()) < const Duration(hours: 24)) {
      throw const CancellationNotAllowedException();
    }
  }

  Future<void> _cancelBookingInternal(String bookingId, {String? reason}) async {
    await _bookings.doc(bookingId).update({
      'status': 'cancelled',
      'cancelledAt': DateTime.now(),
      'cancellationReason': reason,
    });
    // onBookingCancel (Cloud Function) frees the session seat and promotes
    // the next waitlisted booking — no client-side count math needed here.
  }

  @override
  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    await _enforceCancellationPolicy(bookingId);
    await _cancelBookingInternal(bookingId, reason: reason);
  }

  @override
  Future<Booking> rescheduleBooking(String bookingId, String newSessionId) async {
    final oldSnap = await _bookings.doc(bookingId).get();
    final old = Booking.fromMap(oldSnap.data()!);

    // Cancel the old booking (triggers onBookingCancel to free/promote)
    // then create a fresh booking against the new session (triggers
    // onBookingCreate to assign the correct confirmed/waitlisted status).
    // Rescheduling intentionally bypasses the 24h cancellation policy
    // (it's not a cancellation — the user is kept booked, just on a
    // different session) so it calls the internal helper directly.
    await _cancelBookingInternal(bookingId, reason: 'Rescheduled');
    final rebooked = await _createAndAwaitFinalization(
      userId: old.userId,
      sessionId: newSessionId,
      participantId: old.participantId,
      participantName: old.participantName,
    );
    return rebooked;
  }
}
