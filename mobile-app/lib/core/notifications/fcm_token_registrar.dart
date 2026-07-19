import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/repository_providers.dart';
import '../../features/auth/auth_controller.dart';

/// Requests notification permission and stores the device's FCM token on
/// the user's profile (`users/{uid}.fcmTokens`) so
/// backend/functions/src/notifications/dispatch.ts can push to it. Runs on
/// every cold start where a user is signed in, not just a fresh login —
/// failures (permission denied, simulator without APNs, web without a
/// service worker) are swallowed — push is a nice-to-have, never a blocker
/// for using the app.
class FcmTokenRegistrar {
  FcmTokenRegistrar(this._ref);
  final Ref _ref;

  void init() {
    // Ask for notification permission as early as possible — before the
    // user even has an account — so a browsing guest gets the OS prompt at
    // first launch instead of it being silently skipped until they log in.
    // Nothing is saved here; requestPermission() is safe to call again
    // later (a no-op returning the already-decided status once answered),
    // which is exactly what registerForCurrentUser() below does once a
    // token actually has somewhere to be saved.
    _requestPermissionEarly();

    // fireImmediately covers a user already resolved from a persisted
    // session at cold start, not just a fresh login transition — without
    // it, a user who denies the permission prompt once and later enables
    // it manually in iOS Settings would never log in again, so
    // registration would never get a chance to re-run for them. Re-running
    // on every cold start also refreshes a rotated/expired FCM token,
    // which Firebase recommends doing periodically anyway.
    _ref.listen(currentUserProvider, (previous, next) {
      if (next != null) registerForCurrentUser();
    }, fireImmediately: true);
  }

  Future<void> _requestPermissionEarly() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Early notification permission request skipped: $error\n$stackTrace');
      }
    }
  }

  Future<void> registerForCurrentUser() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await messaging.getToken();
      if (token == null) return;

      await _ref.read(firebaseFirestoreProvider).collection('users').doc(user.id).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    } catch (error, stackTrace) {
      // Local/simulator builds without push entitlements throw here —
      // this is expected in dev and shouldn't surface to the user.
      if (kDebugMode) {
        debugPrint('FCM token registration skipped: $error\n$stackTrace');
      }
    }
  }
}

final fcmTokenRegistrarProvider = Provider((ref) {
  final registrar = FcmTokenRegistrar(ref);
  registrar.init();
  return registrar;
});
