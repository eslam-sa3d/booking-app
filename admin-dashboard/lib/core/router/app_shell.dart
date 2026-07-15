import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_controller.dart';
import '../theme/app_theme.dart';

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
  _NavItem(Icons.local_offer_outlined, 'Banners', '/banners'),
  _NavItem(Icons.card_membership_outlined, 'Packages', '/packages'),
  _NavItem(Icons.payments_outlined, 'Payments & Reports', '/payments'),
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

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 240,
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
                        for (final item in _navItems)
                          _SidebarTile(
                            icon: item.icon,
                            label: item.label,
                            isSelected: location.startsWith(item.path),
                            onTap: () => context.go(item.path),
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
                      onTap: () => ref.read(authControllerProvider).logout(),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Expanded(child: child),
        ],
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
