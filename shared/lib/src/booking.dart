import 'enums.dart';

class Booking {
  final String id;
  final String userId;
  final String sessionId;
  final String participantId; // FamilyMember.id, or userId when booking for self
  final String participantName;
  final BookingStatus status;
  final DateTime createdAt;
  final bool isRecurring;
  final String? recurrenceGroupId;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final bool reviewed;

  const Booking({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.participantId,
    required this.participantName,
    this.status = BookingStatus.confirmed,
    required this.createdAt,
    this.isRecurring = false,
    this.recurrenceGroupId,
    this.cancelledAt,
    this.cancellationReason,
    this.reviewed = false,
  });

  Booking copyWith({
    BookingStatus? status,
    DateTime? cancelledAt,
    String? cancellationReason,
    bool? reviewed,
  }) {
    return Booking(
      id: id,
      userId: userId,
      sessionId: sessionId,
      participantId: participantId,
      participantName: participantName,
      status: status ?? this.status,
      createdAt: createdAt,
      isRecurring: isRecurring,
      recurrenceGroupId: recurrenceGroupId,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      reviewed: reviewed ?? this.reviewed,
    );
  }
}
