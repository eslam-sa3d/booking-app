import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

class BookingsRepository {
  BookingsRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('bookings');

  Stream<List<Booking>> watchByStatus(BookingStatus status) {
    return _col.where('status', isEqualTo: status.name).snapshots().map(
          (snap) => snap.docs.map((d) => Booking.fromMap(d.data())).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
        );
  }

  Stream<List<Booking>> watchRecentCancellations() {
    return _col
        .where('status', isEqualTo: BookingStatus.cancelled.name)
        .orderBy('cancelledAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Booking.fromMap(d.data())).toList());
  }

  /// Staff-initiated cancellation — same status-update path the mobile app
  /// uses, so onBookingCancel's waitlist-promotion logic applies here too.
  Future<void> cancel(String bookingId, {String? reason}) => _col.doc(bookingId).update({
        'status': 'cancelled',
        'cancelledAt': DateTime.now(),
        'cancellationReason': reason,
      });
}
