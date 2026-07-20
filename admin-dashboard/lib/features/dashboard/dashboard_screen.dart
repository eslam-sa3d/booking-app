import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shared/shared.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/breakpoints.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../data/repositories/dashboard_repository.dart';

/// One-shot load of the secondary dashboard stats (today's bookings,
/// revenue, upcoming sessions, capacity, expiring packages) — these don't
/// need to be live-streamed, so a `FutureProvider` re-fetching on screen
/// load/refresh is enough.
final _dashboardStatsProvider = FutureProvider<DashboardStats>((ref) {
  return ref.watch(dashboardRepositoryProvider).loadStats();
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final classesAsync = ref.watch(classesRepositoryProvider).watchClasses();
    final waitlistAsync = ref.read(bookingsRepositoryProvider).watchByStatus(BookingStatus.waitlisted);
    final statsAsync = ref.watch(_dashboardStatsProvider);

    return AdminPageScaffold(
      title: l10n.dashboardTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // Two per row on mobile instead of one full-width card per
              // row — one 16px gap between the pair, matching the Wrap's
              // spacing below.
              final cardWidth = context.isMobile ? (constraints.maxWidth - 16) / 2 : 220.0;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  StreamBuilder(
                    stream: classesAsync,
                    builder: (context, snap) => _StatCard(
                      icon: Icons.pool_outlined,
                      label: l10n.dashboardActiveClasses,
                      value: '${snap.data?.length ?? '—'}',
                      route: '/classes',
                      width: cardWidth,
                    ),
                  ),
                  _StatCard(
                    icon: Icons.people_outline,
                    label: l10n.dashboardTotalMembers,
                    value: statsAsync.when(
                      data: (s) => '${s.membersCount}',
                      loading: () => '—',
                      error: (_, _) => '!',
                    ),
                    route: '/members',
                    width: cardWidth,
                  ),
                  StreamBuilder(
                    stream: waitlistAsync,
                    builder: (context, snap) => _StatCard(
                      icon: Icons.hourglass_top_outlined,
                      label: l10n.dashboardWaitlistedBookings,
                      value: '${snap.data?.length ?? '—'}',
                      highlight: (snap.data?.length ?? 0) > 0,
                      route: '/requests',
                      width: cardWidth,
                    ),
                  ),
                  _StatCard(
                    icon: Icons.event_available_outlined,
                    label: l10n.dashboardTodaysBookings,
                    value: statsAsync.when(
                      data: (s) => '${s.todaysBookings}',
                      loading: () => '—',
                      error: (_, _) => '!',
                    ),
                    route: '/calendar',
                    width: cardWidth,
                  ),
                  _StatCard(
                    icon: Icons.payments_outlined,
                    label: l10n.dashboardRevenueThisMonth,
                    value: statsAsync.when(
                      data: (s) => '${s.revenueThisMonth.toStringAsFixed(0)} EGP',
                      loading: () => '—',
                      error: (_, _) => '!',
                    ),
                    route: '/reports',
                    width: cardWidth,
                  ),
                  _StatCard(
                    icon: Icons.event_note_outlined,
                    label: l10n.dashboardUpcomingSessions,
                    value: statsAsync.when(
                      data: (s) => '${s.upcomingSessions}',
                      loading: () => '—',
                      error: (_, _) => '!',
                    ),
                    route: '/calendar',
                    width: cardWidth,
                  ),
                  _StatCard(
                    icon: Icons.warning_amber_outlined,
                    label: l10n.dashboardFullNearFullClasses,
                    value: statsAsync.when(
                      data: (s) => '${s.fullOrNearFullSessions}',
                      loading: () => '—',
                      error: (_, _) => '!',
                    ),
                    highlight: statsAsync.maybeWhen(data: (s) => s.fullOrNearFullSessions > 0, orElse: () => false),
                    route: '/calendar',
                    width: cardWidth,
                  ),
                  _StatCard(
                    icon: Icons.schedule_outlined,
                    label: l10n.dashboardPackagesExpiringSoon,
                    value: statsAsync.when(
                      data: (s) => '${s.expiringPackages}',
                      loading: () => '—',
                      error: (_, _) => '!',
                    ),
                    highlight: statsAsync.maybeWhen(data: (s) => s.expiringPackages > 0, orElse: () => false),
                    route: '/members',
                    width: cardWidth,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            l10n.dashboardSidebarHint,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    required this.route,
    required this.width,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  final double width;

  /// Route showing the full detail behind this stat — the whole card
  /// navigates there on tap.
  final String route;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.go(route),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: highlight ? Colors.orange.shade200 : Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: highlight ? Colors.orange : Colors.teal),
              const SizedBox(height: 12),
              Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
