import '../models/models.dart';

class BookingResult {
  final Booking booking;
  final bool joinedWaitlist;
  const BookingResult({required this.booking, required this.joinedWaitlist});
}

abstract class BookingRepository {
  Future<List<Booking>> getBookingsForUser(String userId);

  /// Creates a booking, or joins the waitlist automatically if the session is
  /// full. If [recurringWeeks] > 1, creates one booking per week sharing a
  /// recurrenceGroupId (best-effort: skips weeks where the slot is full).
  Future<List<BookingResult>> createBooking({
    required String userId,
    required String sessionId,
    required String participantId,
    required String participantName,
    int recurringWeeks = 1,
  });

  Future<void> cancelBooking(String bookingId, {String? reason});

  Future<Booking> rescheduleBooking(String bookingId, String newSessionId);
}
