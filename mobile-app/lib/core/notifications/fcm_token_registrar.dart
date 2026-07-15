import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/repository_providers.dart';
import '../../features/auth/auth_controller.dart';

/// Requests notification permission and stores the device's FCM token on
/// the user's profile (`users/{uid}.fcmTokens`) so
/// backend/functions/src/notifications/dispatch.ts can push to it. Runs
/// once per login; failures (permission denied, simulator without APNs,
/// web without a service worker) are swallowed — push is a nice-to-have,
/// never a blocker for using the app.
class FcmTokenRegistrar {
  FcmTokenRegistrar(this._ref);
  final Ref _ref;

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

final fcmTokenRegistrarProvider = Provider((ref) => FcmTokenRegistrar(ref));
