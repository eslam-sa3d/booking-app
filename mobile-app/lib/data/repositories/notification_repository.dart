import '../models/models.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications(String userId);

  Future<void> markAsRead(String userId, String id);

  Future<void> markAllAsRead(String userId);
}
