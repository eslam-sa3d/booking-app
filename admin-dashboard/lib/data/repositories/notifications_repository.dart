import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationDefinition {
  final String id;
  final String type;
  final String title;
  final String titleAr;
  final String body;
  final String bodyAr;
  final String target; // 'all' | 'segment' | 'user'
  final String? targetUserId;
  final String? targetSegment;
  final DateTime createdAt;
  final String createdBy;
  final String status; // 'draft' | 'scheduled' | 'sent'

  const NotificationDefinition({
    required this.id,
    required this.type,
    required this.title,
    required this.titleAr,
    required this.body,
    required this.bodyAr,
    required this.target,
    this.targetUserId,
    this.targetSegment,
    required this.createdAt,
    required this.createdBy,
    this.status = 'sent',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'title': title,
        'titleAr': titleAr,
        'body': body,
        'bodyAr': bodyAr,
        'target': target,
        'targetUserId': targetUserId,
        'targetSegment': targetSegment,
        'createdAt': createdAt,
        'createdBy': createdBy,
        'status': status,
      };

  factory NotificationDefinition.fromMap(Map<String, dynamic> map) => NotificationDefinition(
        id: map['id'] as String,
        type: map['type'] as String? ?? 'general',
        title: map['title'] as String? ?? '',
        titleAr: map['titleAr'] as String? ?? '',
        body: map['body'] as String? ?? '',
        bodyAr: map['bodyAr'] as String? ?? '',
        target: map['target'] as String? ?? 'all',
        targetUserId: map['targetUserId'] as String?,
        targetSegment: map['targetSegment'] as String?,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        createdBy: map['createdBy'] as String? ?? '',
        status: map['status'] as String? ?? 'sent',
      );
}

/// Writing here fires `dispatchNotification` (backend/functions/src/notifications/dispatch.ts)
/// — currently a stub logging a warning; full FCM fan-out is a follow-up.
class NotificationsRepository {
  NotificationsRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('notifications');

  Stream<List<NotificationDefinition>> watchAll() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map((d) => NotificationDefinition.fromMap(d.data())).toList(),
        );
  }

  Future<void> compose(NotificationDefinition definition) async {
    final ref = definition.id.isEmpty ? _col.doc() : _col.doc(definition.id);
    await ref.set(definition.toMap()..['id'] = ref.id);
  }
}
