import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_controller.dart';
import '../../features/auth/login_screen.dart';
import '../../features/banners/banners_screen.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/classes/classes_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/instructors/instructors_screen.dart';
import '../../features/members/members_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/packages/packages_screen.dart';
import '../../features/payment_methods/payment_methods_screen.dart';
import '../../features/payments/payments_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/requests/requests_screen.dart';
import '../../features/settings/app_settings_screen.dart';
import '../../features/staff/staff_screen.dart';
import 'access.dart';
import 'app_shell.dart';

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, _) => notifyListeners());
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoading = authState.isLoading && !authState.hasValue && !authState.hasError;
      if (isLoading) return null;

      final session = authState.value;
      final isLoggedInAsStaff = session != null && session.isStaffOrAdmin;
      final onLoginPage = state.matchedLocation == '/login';

      if (!isLoggedInAsStaff && !onLoginPage) return '/login';
      if (isLoggedInAsStaff && onLoginPage) return '/dashboard';
      if (isLoggedInAsStaff && !session.isAdmin && isPathAdminOnly(state.matchedLocation)) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/requests', builder: (context, state) => const RequestsScreen()),
          GoRoute(path: '/classes', builder: (context, state) => const ClassesScreen()),
          GoRoute(path: '/calendar', builder: (context, state) => const CalendarScreen()),
          GoRoute(path: '/categories', builder: (context, state) => const CategoriesScreen()),
          GoRoute(path: '/banners', builder: (context, state) => const BannersScreen()),
          GoRoute(path: '/packages', builder: (context, state) => const PackagesScreen()),
          GoRoute(path: '/payments', builder: (context, state) => const PaymentsScreen()),
          GoRoute(path: '/payment-methods', builder: (context, state) => const PaymentMethodsScreen()),
          GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
          GoRoute(path: '/members', builder: (context, state) => const MembersScreen()),
          GoRoute(path: '/instructors', builder: (context, state) => const InstructorsScreen()),
          GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
          GoRoute(path: '/settings', builder: (context, state) => const AppSettingsScreen()),
          GoRoute(path: '/staff', builder: (context, state) => const StaffScreen()),
        ],
      ),
    ],
  );
});
