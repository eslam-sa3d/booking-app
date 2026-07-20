import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_controller.dart';
import '../localization/generated/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../theme/app_theme.dart';
import '../theme/breakpoints.dart';
import 'access.dart';

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem(this.icon, this.label, this.path);
}

List<_NavItem> _navItems(AppLocalizations l10n) => [
      _NavItem(Icons.dashboard_outlined, l10n.navDashboard, '/dashboard'),
      _NavItem(Icons.inbox_outlined, l10n.navRequests, '/requests'),
      _NavItem(Icons.pool_outlined, l10n.navClasses, '/classes'),
      _NavItem(Icons.calendar_month_outlined, l10n.navCalendar, '/calendar'),
      _NavItem(Icons.sell_outlined, l10n.navCategories, '/categories'),
      _NavItem(Icons.local_offer_outlined, l10n.navBanners, '/banners'),
      _NavItem(Icons.card_membership_outlined, l10n.navPackages, '/packages'),
      _NavItem(Icons.payments_outlined, l10n.navPayments, '/payments'),
      _NavItem(Icons.credit_card_outlined, l10n.navPaymentMethods, '/payment-methods'),
      _NavItem(Icons.bar_chart_outlined, l10n.navReports, '/reports'),
      _NavItem(Icons.people_outline, l10n.navMembers, '/members'),
      _NavItem(Icons.badge_outlined, l10n.navInstructors, '/instructors'),
      _NavItem(Icons.notifications_outlined, l10n.navNotifications, '/notifications'),
      _NavItem(Icons.settings_outlined, l10n.navSettings, '/settings'),
      _NavItem(Icons.admin_panel_settings_outlined, l10n.navStaff, '/staff'),
    ];

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  // Desktop/tablet sidebar starts expanded (matches the previous
  // always-visible behavior); mobile always starts collapsed via its own
  // Drawer below, regardless of this flag.
  bool _sidebarExpanded = true;

  static const double _sidebarWidth = 240;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final location = GoRouterState.of(context).matchedLocation;
    final session = ref.watch(authStateProvider).value;
    final isAdmin = session?.isAdmin ?? false;
    final navItems = _navItems(l10n);
    final visibleNavItems = isAdmin ? navItems : navItems.where((item) => !isPathAdminOnly(item.path));

    String currentLabel = 'Swim Academy';
    for (final item in visibleNavItems) {
      if (location.startsWith(item.path)) {
        currentLabel = item.label;
        break;
      }
    }

    if (context.isMobile) {
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
            onClose: () => Navigator.of(context).pop(),
          ),
        ),
        body: widget.child,
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.sidebar,
        foregroundColor: Colors.white,
        title: Text(currentLabel),
        leading: IconButton(
          icon: Icon(_sidebarExpanded ? Icons.menu_open : Icons.menu),
          tooltip: _sidebarExpanded ? l10n.navCollapseMenu : l10n.navExpandMenu,
          onPressed: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
        ),
      ),
      body: Row(
        children: [
          ClipRect(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: _sidebarExpanded ? _sidebarWidth : 0,
              child: OverflowBox(
                alignment: AlignmentDirectional.centerStart,
                minWidth: _sidebarWidth,
                maxWidth: _sidebarWidth,
                child: _SidebarContent(
                  navItems: visibleNavItems,
                  location: location,
                  session: session,
                  onItemTap: context.go,
                  onSignOut: () => ref.read(authControllerProvider).logout(),
                ),
              ),
            ),
          ),
          Expanded(child: widget.child),
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
    this.onClose,
  });

  final Iterable<_NavItem> navItems;
  final String location;
  final Object? session;
  final ValueChanged<String> onItemTap;
  final VoidCallback onSignOut;
  // Only set on mobile, where the sidebar is a dismissible Drawer; the
  // desktop/tablet layout collapses via the AppBar toggle instead.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: AppColors.sidebar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 12, 24),
              child: Row(
                children: [
                  const Icon(Icons.pool_rounded, color: AppColors.primary, size: 26),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Swim Academy',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                  ),
                  if (onClose != null)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      tooltip: l10n.navCloseMenu,
                      onPressed: onClose,
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
            Consumer(
              builder: (context, ref, _) {
                final isArabic = ref.watch(isArabicProvider);
                return _SidebarTile(
                  icon: Icons.translate_rounded,
                  label: isArabic ? l10n.navSwitchToEnglish : l10n.navSwitchToArabic,
                  isSelected: false,
                  onTap: () => ref.read(localeProvider.notifier).toggle(),
                );
              },
            ),
            if (session != null)
              _SidebarTile(
                icon: Icons.logout_rounded,
                label: l10n.navSignOut,
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
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
