import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../../data/repositories/booking_repository.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/auth_controller.dart';
import '../providers/shared_preferences_provider.dart';
import '../../features/booking/booking_calendar_screen.dart';
import '../../features/booking/booking_confirmation_screen.dart';
import '../../features/classes/class_details_screen.dart';
import '../../features/family/family_member_form_screen.dart';
import '../../features/family/family_members_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/my_bookings/my_bookings_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/packages/packages_screen.dart';
import '../../features/payment/checkout_screen.dart';
import '../../features/payment/payment_history_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/support_faq_screen.dart';
import 'app_shell.dart';

const _protectedPathPrefixes = [
  '/bookings',
  '/family',
  '/packages',
  '/checkout',
  '/payment-history',
  '/notifications',
];

/// Bridges Riverpod's [authControllerProvider] to go_router's
/// [GoRouter.refreshListenable] so the router re-evaluates `redirect` when
/// auth state changes, WITHOUT rebuilding the [GoRouter] instance itself —
/// recreating the router on every auth change tears down and recreates the
/// whole navigator stack mid-flight, which crashes any screen with async
/// work pending in initState (e.g. the splash screen redirect logic).
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

/// Built once and cached for the app's lifetime — the provider body never
/// calls `ref.watch`, so no dependency change ever recreates the router.
final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    // Every navigation driven by auth state goes through this single
    // callback, keyed off refreshListenable. Splash used to also call
    // context.go() itself once authControllerProvider.future resolved —
    // that ran independently of (and raced) this callback reacting to the
    // exact same state change, since go_router debounces refreshListenable
    // reactions onto their own microtask. Two route-processing operations
    // landing in the same frame produced two Page objects for the same
    // location before the Navigator finished settling the first, which
    // crashed with a duplicate-page-key assertion. Routing splash's exit
    // through here too removes the second, competing participant.
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isLoggedIn = authState.value != null;
      final isResolving = authState.isLoading && !authState.hasValue && !authState.hasError;
      final path = state.matchedLocation;

      if (path == '/splash') {
        if (isResolving) return null;
        final seenOnboarding = ref.read(sharedPreferencesProvider).getBool(kOnboardingSeenKey) ?? false;
        // Guests can browse Home freely; booking/profile actions gate on login individually.
        return seenOnboarding ? '/home' : '/onboarding';
      }

      if (isResolving) return null;
      final isProtected = _protectedPathPrefixes.any((p) => path.startsWith(p));
      if (isProtected && !isLoggedIn) {
        return '/login?redirect=${Uri.encodeComponent(path)}';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/otp',
        builder: (context, state) => OtpScreen(destination: state.uri.queryParameters['destination'] ?? ''),
      ),
      GoRoute(
        path: '/class/:classId',
        builder: (context, state) => ClassDetailsScreen(classId: state.pathParameters['classId']!),
      ),
      GoRoute(
        path: '/booking-confirmation',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BookingConfirmationScreen(
            results: extra['results'] as List<BookingResult>,
            session: extra['session'] as SwimSession,
            swimClass: extra['swimClass'] as SwimClass,
          );
        },
      ),
      GoRoute(path: '/family', builder: (context, state) => const FamilyMembersScreen()),
      GoRoute(path: '/family/add', builder: (context, state) => const FamilyMemberFormScreen()),
      GoRoute(
        path: '/family/edit/:memberId',
        builder: (context, state) => FamilyMemberFormScreen(memberId: state.pathParameters['memberId']),
      ),
      GoRoute(path: '/packages', builder: (context, state) => const PackagesScreen()),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => CheckoutScreen(package: state.extra as SwimPackage),
      ),
      GoRoute(path: '/payment-history', builder: (context, state) => const PaymentHistoryScreen()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/settings/faq', builder: (context, state) => const SupportFaqScreen()),
      GoRoute(path: '/profile/edit', builder: (context, state) => const EditProfileScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (context, state) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/bookings', builder: (context, state) => const MyBookingsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/calendar', builder: (context, state) => const BookingCalendarScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())]),
        ],
      ),
    ],
  );
});
