import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAnalyticsProvider = Provider<FirebaseAnalytics>((ref) => FirebaseAnalytics.instance);

final analyticsServiceProvider = Provider<AnalyticsService>((ref) => AnalyticsService(ref.watch(firebaseAnalyticsProvider)));

/// Thin, typed wrapper around the key events the build spec calls out:
/// registration, booking, and payment. Keeping the event names/params here
/// (rather than scattering raw `logEvent` calls) is what keeps them
/// consistent across every call site.
class AnalyticsService {
  AnalyticsService(this._analytics);
  final FirebaseAnalytics _analytics;

  Future<void> logRegistration({required String method}) =>
      _analytics.logSignUp(signUpMethod: method);

  Future<void> logLogin({required String method}) => _analytics.logLogin(loginMethod: method);

  Future<void> logBookingCreated({required String classId, required String sessionId, required bool waitlisted}) =>
      _analytics.logEvent(
        name: 'booking_created',
        parameters: {'class_id': classId, 'session_id': sessionId, 'waitlisted': waitlisted},
      );

  Future<void> logBookingCancelled({required String bookingId}) =>
      _analytics.logEvent(name: 'booking_cancelled', parameters: {'booking_id': bookingId});

  Future<void> logPackagePurchaseStarted({required String packageId, required double amount}) =>
      _analytics.logEvent(
        name: 'package_purchase_started',
        parameters: {'package_id': packageId, 'value': amount, 'currency': 'EGP'},
      );

  Future<void> logPaymentCompleted({required String packageId, required double amount, required bool success}) =>
      success
          ? _analytics.logPurchase(currency: 'EGP', value: amount, parameters: {'package_id': packageId})
          : _analytics.logEvent(
              name: 'payment_failed',
              parameters: {'package_id': packageId, 'value': amount, 'currency': 'EGP'},
            );
}
