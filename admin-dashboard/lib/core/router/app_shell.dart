import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_controller.dart';
import '../theme/app_theme.dart';
import '../theme/breakpoints.dart';
import 'access.dart';

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem(this.icon, this.label, this.path);
}

const _navItems = [
  _NavItem(Icons.dashboard_outlined, 'Dashboard', '/dashboard'),
  _NavItem(Icons.inbox_outlined, 'Requests', '/requests'),
  _NavItem(Icons.pool_outlined, 'Classes', '/classes'),
  _NavItem(Icons.calendar_month_outlined, 'Calendar', '/calendar'),
  _NavItem(Icons.sell_outlined, 'Categories', '/categories'),
  _NavItem(Icons.local_offer_outlined, 'Banners', '/banners'),
  _NavItem(Icons.card_membership_outlined, 'Packages', '/packages'),
  _NavItem(Icons.payments_outlined, 'Payments', '/payments'),
  _NavItem(Icons.credit_card_outlined, 'Payment Methods', '/payment-methods'),
  _NavItem(Icons.bar_chart_outlined, 'Reports & Analytics', '/reports'),
  _NavItem(Icons.people_outline, 'Members', '/members'),
  _NavItem(Icons.badge_outlined, 'Instructors', '/instructors'),
  _NavItem(Icons.notifications_outlined, 'Notifications', '/notifications'),
  _NavItem(Icons.settings_outlined, 'App Content & Settings', '/settings'),
  _NavItem(Icons.admin_panel_settings_outlined, 'Staff Accounts', '/staff'),
];

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final session = ref.watch(authStateProvider).value;
    final isAdmin = session?.isAdmin ?? false;
    final visibleNavItems = isAdmin ? _navItems : _navItems.where((item) => !isPathAdminOnly(item.path));

    if (context.isMobile) {
      String currentLabel = 'Swim Academy';
      for (final item in visibleNavItems) {
        if (location.startsWith(item.path)) {
          currentLabel = item.label;
          break;
        }
      }
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.sidebar,
          foregroundColor: Colors.white,
          title: Text(currentLabel),
        ),
        drawer: Drawer(
          backgroundColor: AppColors.sidebar,
          child: _SidebarContent(
            navItems: visibleNavItems,
            location: location,
            session: session,
            onItemTap: (path) {
              Navigator.of(context).pop();
              context.go(path);
            },
            onSignOut: () {
              Navigator.of(context).pop();
              ref.read(authControllerProvider).logout();
            },
          ),
        ),
        body: child,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 240,
            child: _SidebarContent(
              navItems: visibleNavItems,
              location: location,
              session: session,
              onItemTap: context.go,
              onSignOut: () => ref.read(authControllerProvider).logout(),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  const _SidebarContent({
    required this.navItems,
    required this.location,
    required this.session,
    required this.onItemTap,
    required this.onSignOut,
  });

  final Iterable<_NavItem> navItems;
  final String location;
  final Object? session;
  final ValueChanged<String> onItemTap;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sidebar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Row(
                children: [
                  Icon(Icons.pool_rounded, color: AppColors.primary, size: 26),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Swim Academy',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final item in navItems)
                    _SidebarTile(
                      icon: item.icon,
                      label: item.label,
                      isSelected: location.startsWith(item.path),
                      onTap: () => onItemTap(item.path),
                    ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            if (session != null)
              _SidebarTile(
                icon: Icons.logout_rounded,
                label: 'Sign out',
                isSelected: false,
                onTap: onSignOut,
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({required this.icon, required this.label, required this.isSelected, required this.onTap});

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? AppColors.primary : Colors.white70),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
