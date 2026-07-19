import 'enums.dart';
import 'firestore_codec.dart';

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
  // Set server-side by onBookingCreate when a confirmed booking draws a
  // session credit from one of the user's own active sessionPack packages;
  // null when paid for standalone (or when no package with sessions
  // remaining was available). onBookingCancel refunds the credit here.
  final String? userPackageId;

  const Booking({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.participantId,
    required this.participantName,
    this.status = BookingStatus.pending,
    required this.createdAt,
    this.isRecurring = false,
    this.recurrenceGroupId,
    this.cancelledAt,
    this.cancellationReason,
    this.reviewed = false,
    this.userPackageId,
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
      userPackageId: userPackageId,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'sessionId': sessionId,
        'participantId': participantId,
        'participantName': participantName,
        'status': status.name,
        'createdAt': createdAt,
        'isRecurring': isRecurring,
        'recurrenceGroupId': recurrenceGroupId,
        'cancelledAt': cancelledAt,
        'cancellationReason': cancellationReason,
        'reviewed': reviewed,
        'userPackageId': userPackageId,
      };

  factory Booking.fromMap(Map<String, dynamic> map) => Booking(
        id: map['id'] as String,
        userId: map['userId'] as String,
        sessionId: map['sessionId'] as String,
        participantId: map['participantId'] as String,
        participantName: map['participantName'] as String,
        status: BookingStatus.fromName(map['status'] as String? ?? 'pending'),
        createdAt: parseTimestamp(map['createdAt']),
        isRecurring: map['isRecurring'] as bool? ?? false,
        recurrenceGroupId: map['recurrenceGroupId'] as String?,
        cancelledAt: parseTimestampOrNull(map['cancelledAt']),
        cancellationReason: map['cancellationReason'] as String?,
        reviewed: map['reviewed'] as bool? ?? false,
        userPackageId: map['userPackageId'] as String?,
      );
}
