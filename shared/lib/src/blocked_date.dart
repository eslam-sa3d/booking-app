import 'firestore_codec.dart';

/// A date (optionally scoped to one branch) closed to new sessions/bookings.
class BlockedDate {
  final String id;
  final DateTime date;
  final String? branchId; // null = all branches
  final String reason;
  final String createdBy;
  final DateTime createdAt;

  const BlockedDate({
    required this.id,
    required this.date,
    this.branchId,
    required this.reason,
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'branchId': branchId,
        'reason': reason,
        'createdBy': createdBy,
        'createdAt': createdAt,
      };

  factory BlockedDate.fromMap(Map<String, dynamic> map) => BlockedDate(
        id: map['id'] as String,
        date: parseTimestamp(map['date']),
        branchId: map['branchId'] as String?,
        reason: map['reason'] as String? ?? '',
        createdBy: map['createdBy'] as String? ?? '',
        createdAt: parseTimestamp(map['createdAt']),
      );
}
