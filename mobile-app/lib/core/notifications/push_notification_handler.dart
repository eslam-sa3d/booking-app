import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router/app_router.dart';

/// Shows a local notification for pushes that arrive while the app is in
/// the foreground (Firebase Messaging never surfaces those on its own —
/// `FirebaseMessaging.onMessage` fires, but nothing is displayed unless the
/// app draws it itself), and navigates when the user taps a push that
/// arrived while the app was backgrounded.
///
/// See backend/functions/src/lib/notify.ts for the `data` payload shape:
/// always `type`, plus `bookingId` when the notification relates to a
/// booking.
class PushNotificationHandler {
  PushNotificationHandler(this._ref);
  final Ref _ref;

  static const _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notifications',
    description: 'Booking updates, reminders and promotions.',
    importance: Importance.high,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _localNotifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (response) => _handlePayload(response.payload),
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);

      FirebaseMessaging.onMessage.listen(_showForegroundNotification);
      FirebaseMessaging.onMessageOpenedApp.listen(_navigateForMessage);

      // Covers the case where a push launched the app from a terminated
      // state (as opposed to bringing an already-running app to the
      // foreground, which onMessageOpenedApp handles).
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        // Navigating this early in the app's lifecycle races go_router's
        // redirect/refreshListenable machinery, which is still settling
        // auth state right after a cold start — hitting that window
        // reliably crashes with a duplicate GlobalKey assertion in
        // NavigatorState (a known class of go_router timing bug). A push
        // that launched the app from terminated is inherently the riskiest
        // case for this, since it navigates as early as possible; a short
        // delay lets initial redirect/auth resolution finish first.
        await Future.delayed(const Duration(seconds: 3));
        _navigateForMessage(initialMessage);
      }
    } catch (error, stackTrace) {
      // Push is best-effort everywhere else in this app (see
      // FcmTokenRegistrar) — a setup failure here shouldn't block startup.
      if (kDebugMode) {
        debugPrint('Push notification handler setup skipped: $error\n$stackTrace');
      }
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: _encodePayload(message.data),
    );
  }

  void _navigateForMessage(RemoteMessage message) => _handlePayload(_encodePayload(message.data));

  void _handlePayload(String? payload) {
    if (payload == null) return;
    final data = Uri.splitQueryString(payload);
    final router = _ref.read(goRouterProvider);
    // A specific booking screen isn't addressable by id today, so route to
    // a reasonable default: the bookings list for booking-related pushes,
    // otherwise the notifications inbox.
    if (data['bookingId'] != null) {
      // /bookings is a StatefulShellBranch destination, not a standalone
      // route — push()ing it from outside the shell stacks a second,
      // independently-keyed page instance on top of the shell's own cached
      // branch page, which go_router's Navigator rejects with a duplicate
      // page-key assertion. go() switches the shell to that branch instead.
      router.go('/bookings');
    } else {
      router.push('/notifications');
    }
  }

  String _encodePayload(Map<String, dynamic> data) =>
      Uri(queryParameters: data.map((key, value) => MapEntry(key, '$value'))).query;
}

final pushNotificationHandlerProvider = Provider<PushNotificationHandler>((ref) {
  final handler = PushNotificationHandler(ref);
  handler.init();
  return handler;
});
