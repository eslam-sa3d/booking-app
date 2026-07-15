import '../../repositories/notification_repository.dart';
import '../../models/models.dart';
import 'mock_database.dart';

class MockNotificationRepository implements NotificationRepository {
  final _db = MockDatabase.instance;

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 350));

  @override
  Future<List<AppNotification>> getNotifications(String userId) async {
    await _delay();
    return _db.notifications.where((n) => n.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> markAsRead(String id) async {
    await _delay();
    final index = _db.notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _db.notifications[index] = _db.notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await _delay();
    for (int i = 0; i < _db.notifications.length; i++) {
      if (_db.notifications[i].userId == userId) {
        _db.notifications[i] = _db.notifications[i].copyWith(isRead: true);
      }
    }
  }
}
