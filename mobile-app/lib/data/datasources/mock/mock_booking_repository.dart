import '../../models/models.dart';
import '../../repositories/booking_repository.dart';
import 'mock_database.dart';

class MockBookingRepository implements BookingRepository {
  final _db = MockDatabase.instance;

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 500));

  @override
  Future<List<Booking>> getBookingsForUser(String userId) async {
    await _delay();
    return _db.bookings.where((b) => b.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<BookingResult>> createBooking({
    required String userId,
    required String sessionId,
    required String participantId,
    required String participantName,
    int recurringWeeks = 1,
  }) async {
    await _delay();
    final results = <BookingResult>[];
    final recurrenceGroupId = recurringWeeks > 1 ? _db.nextId('rec') : null;

    var currentSessionId = sessionId;
    for (int week = 0; week < recurringWeeks; week++) {
      final sessionIndex = _db.sessions.indexWhere((s) => s.id == currentSessionId);
      if (sessionIndex == -1) break;
      final session = _db.sessions[sessionIndex];

      final joinsWaitlist = session.isFull;
      final booking = Booking(
        id: _db.nextId('bk'),
        userId: userId,
        sessionId: session.id,
        participantId: participantId,
        participantName: participantName,
        status: joinsWaitlist ? BookingStatus.waitlisted : BookingStatus.confirmed,
        createdAt: DateTime.now(),
        isRecurring: recurringWeeks > 1,
        recurrenceGroupId: recurrenceGroupId,
      );
      _db.bookings.add(booking);
      results.add(BookingResult(booking: booking, joinedWaitlist: joinsWaitlist));

      if (!joinsWaitlist) {
        _db.sessions[sessionIndex] = session.copyWith(bookedCount: session.bookedCount + 1);
      } else {
        _db.sessions[sessionIndex] = session.copyWith(waitlistCount: session.waitlistCount + 1);
      }

      _db.notifications.add(
        AppNotification(
          id: _db.nextId('n'),
          userId: userId,
          type: joinsWaitlist ? NotificationType.waitlistPromoted : NotificationType.bookingConfirmed,
          title: joinsWaitlist ? 'Added to waitlist' : 'Booking confirmed',
          titleAr: joinsWaitlist ? 'تمت الإضافة لقائمة الانتظار' : 'تم تأكيد الحجز',
          body: joinsWaitlist
              ? 'You are on the waitlist for $participantName.'
              : 'Your booking for $participantName is confirmed.',
          bodyAr: joinsWaitlist
              ? 'أنت الآن في قائمة الانتظار لـ $participantName.'
              : 'تم تأكيد حجزك لـ $participantName.',
          createdAt: DateTime.now(),
          relatedBookingId: booking.id,
        ),
      );

      // find next week's occurrence of the same weekly slot, if any
      if (week < recurringWeeks - 1) {
        final nextWeekDate = session.date.add(const Duration(days: 7));
        final next = _db.sessions.firstWhere(
          (s) =>
              s.classId == session.classId &&
              s.startMinutes == session.startMinutes &&
              s.date.year == nextWeekDate.year &&
              s.date.month == nextWeekDate.month &&
              s.date.day == nextWeekDate.day,
          orElse: () => session,
        );
        if (next.id == session.id) break;
        currentSessionId = next.id;
      }
    }

    return results;
  }

  @override
  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    await _delay();
    final index = _db.bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return;
    final booking = _db.bookings[index];

    final sessionIndex = _db.sessions.indexWhere((s) => s.id == booking.sessionId);
    if (sessionIndex != -1) {
      final session = _db.sessions[sessionIndex];
      if (session.startDateTime.difference(DateTime.now()) < const Duration(hours: 24)) {
        throw const CancellationNotAllowedException();
      }
    }

    _db.bookings[index] = booking.copyWith(
      status: BookingStatus.cancelled,
      cancelledAt: DateTime.now(),
      cancellationReason: reason,
    );

    if (sessionIndex != -1) {
      final session = _db.sessions[sessionIndex];
      if (booking.status == BookingStatus.confirmed) {
        _db.sessions[sessionIndex] = session.copyWith(bookedCount: (session.bookedCount - 1).clamp(0, 999));
      } else if (booking.status == BookingStatus.waitlisted) {
        _db.sessions[sessionIndex] = session.copyWith(waitlistCount: (session.waitlistCount - 1).clamp(0, 999));
      }
    }
  }

  @override
  Future<Booking> rescheduleBooking(String bookingId, String newSessionId) async {
    await _delay();
    final index = _db.bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) throw Exception('Booking not found');
    final oldBooking = _db.bookings[index];

    final oldSessionIndex = _db.sessions.indexWhere((s) => s.id == oldBooking.sessionId);
    if (oldSessionIndex != -1 && oldBooking.status == BookingStatus.confirmed) {
      final oldSession = _db.sessions[oldSessionIndex];
      _db.sessions[oldSessionIndex] = oldSession.copyWith(bookedCount: (oldSession.bookedCount - 1).clamp(0, 999));
    }

    final newSessionIndex = _db.sessions.indexWhere((s) => s.id == newSessionId);
    final newSession = newSessionIndex != -1 ? _db.sessions[newSessionIndex] : null;
    final joinsWaitlist = newSession?.isFull ?? false;

    final updated = Booking(
      id: oldBooking.id,
      userId: oldBooking.userId,
      sessionId: newSessionId,
      participantId: oldBooking.participantId,
      participantName: oldBooking.participantName,
      status: joinsWaitlist ? BookingStatus.waitlisted : BookingStatus.confirmed,
      createdAt: oldBooking.createdAt,
      isRecurring: false,
      recurrenceGroupId: null,
    );
    _db.bookings[index] = updated;

    if (newSessionIndex != -1) {
      if (joinsWaitlist) {
        _db.sessions[newSessionIndex] = newSession!.copyWith(waitlistCount: newSession.waitlistCount + 1);
      } else {
        _db.sessions[newSessionIndex] = newSession!.copyWith(bookedCount: newSession.bookedCount + 1);
      }
    }

    return updated;
  }
}
