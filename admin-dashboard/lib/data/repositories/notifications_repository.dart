import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

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
  final DateTime? scheduledFor;
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
    this.scheduledFor,
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
        'scheduledFor': scheduledFor,
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
        scheduledFor: (map['scheduledFor'] as Timestamp?)?.toDate(),
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        createdBy: map['createdBy'] as String? ?? '',
        status: map['status'] as String? ?? 'sent',
      );
}

/// Delivery/read counters for a single broadcast, derived from the
/// `users/{uid}/inbox/{id}` copies that `notifyUsers` fan-out writes
/// (each tagged with `sourceNotificationId`).
class NotificationStats {
  const NotificationStats({required this.delivered, required this.read});
  final int delivered;
  final int read;
}

/// Writing here fires `onNotificationCreated` / `dispatchScheduledNotifications`
/// (backend/functions/src/notifications/dispatch.ts). A doc created with
/// `status: 'sent'` dispatches immediately (real FCM push + inbox fan-out);
/// a doc created with `status: 'scheduled'` and a `scheduledFor` timestamp is
/// picked up by the scheduled function once that time arrives.
class NotificationsRepository {
  NotificationsRepository(this._db, this._functions);
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('notifications');

  Stream<List<NotificationDefinition>> watchAll() {
    return _col.orderBy('createdAt', descending: true).snapshots().map(
          // NotificationDefinition.fromMap does a non-nullable cast on `id`
          // — inject it from the query snapshot's own document ID rather
          // than trusting the document body to contain one, so a single
          // malformed/hand-written doc (missing `id`) can't throw and take
          // down the entire broadcast list.
          (snap) => snap.docs.map((d) => NotificationDefinition.fromMap({...d.data(), 'id': d.id})).toList(),
        );
  }

  Future<void> compose(NotificationDefinition definition) async {
    final ref = definition.id.isEmpty ? _col.doc() : _col.doc(definition.id);
    await ref.set(definition.toMap()..['id'] = ref.id);
  }

  /// Counts delivered (fanned-out) and read inbox copies for [notificationId]
  /// across every user's `inbox` subcollection. Routed through the
  /// `getNotificationStats` callable (Admin SDK, bypasses rules) rather than
  /// a client-side collectionGroup query — Firestore's security rules can't
  /// reliably authorize an OR of a wildcard-bound owner check and a
  /// wildcard-independent staff check for collectionGroup list queries, and
  /// granting staff broad client-side read access across every customer's
  /// inbox is a bigger permission surface than this feature needs anyway.
  Future<NotificationStats> getStats(String notificationId) async {
    final result = await _functions.httpsCallable('getNotificationStats').call({'notificationId': notificationId});
    final data = Map<String, dynamic>.from(result.data as Map);
    return NotificationStats(delivered: data['delivered'] as int, read: data['read'] as int);
  }
}
