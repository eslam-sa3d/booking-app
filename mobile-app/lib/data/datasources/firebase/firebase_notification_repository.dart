import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/models.dart';
import '../../repositories/notification_repository.dart';

class FirebaseNotificationRepository implements NotificationRepository {
  FirebaseNotificationRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _db.collection('users').doc(userId).collection('inbox');

  @override
  Future<List<AppNotification>> getNotifications(String userId) async {
    final snap = await _col(userId).get();
    // The Cloud Function fan-out (backend/functions/src/lib/notify.ts) never
    // writes a `userId` field into these docs — it's already implicit in the
    // `users/{userId}/inbox` path they live at. AppNotification.fromMap
    // requires one, so it's injected here from the query parameter rather
    // than expecting the backend to duplicate it into every document.
    // `id` is injected from the doc snapshot for the same reason `notify.ts`
    // does set it, but a single hand-written/malformed doc missing it would
    // otherwise throw on AppNotification.fromMap's non-nullable cast and
    // take down this whole list (the admin dashboard's broadcast list hit
    // exactly this failure mode — see notifications_repository.dart).
    final notifications = snap.docs
        .map((d) => AppNotification.fromMap({...d.data(), 'id': d.id, 'userId': userId}))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notifications;
  }

  @override
  Future<void> markAsRead(String userId, String id) => _col(userId).doc(id).update({'isRead': true});

  @override
  Future<void> markAllAsRead(String userId) async {
    final snap = await _col(userId).where('isRead', isEqualTo: false).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
