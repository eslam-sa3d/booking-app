import '../models/models.dart';

class BookingResult {
  final Booking booking;
  final bool joinedWaitlist;
  const BookingResult({required this.booking, required this.joinedWaitlist});
}

/// Thrown by [BookingRepository.cancelBooking] when the session starts
/// within the 24h free-cancellation window. Carries a display-ready
/// [message]; UI call sites should generally catch this type specifically
/// and show a localized string rather than [message] itself (which is not
/// localized), mirroring how other repository errors surface to the UI.
class CancellationNotAllowedException implements Exception {
  const CancellationNotAllowedException([this.message = 'Cancellations must be made at least 24 hours before the session starts.']);
  final String message;

  @override
  String toString() => message;
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
