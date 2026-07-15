import 'enums.dart';

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String titleAr;
  final String body;
  final String bodyAr;
  final DateTime createdAt;
  final bool isRead;
  final String? relatedBookingId;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.titleAr,
    required this.body,
    required this.bodyAr,
    required this.createdAt,
    this.isRead = false,
    this.relatedBookingId,
  });

  String localizedTitle(bool isArabic) => isArabic ? titleAr : title;
  String localizedBody(bool isArabic) => isArabic ? bodyAr : body;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      userId: userId,
      type: type,
      title: title,
      titleAr: titleAr,
      body: body,
      bodyAr: bodyAr,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      relatedBookingId: relatedBookingId,
    );
  }
}
