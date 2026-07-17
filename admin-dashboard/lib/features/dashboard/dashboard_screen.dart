import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shared/shared.dart';

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
    final classesAsync = ref.watch(classesRepositoryProvider).watchClasses();
    final membersAsync = ref.watch(membersRepositoryProvider).watchAll();
    final waitlistAsync = ref.read(bookingsRepositoryProvider).watchByStatus(BookingStatus.waitlisted);
    final statsAsync = ref.watch(_dashboardStatsProvider);

    return AdminPageScaffold(
      title: 'Dashboard',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              StreamBuilder(
                stream: classesAsync,
                builder: (context, snap) => _StatCard(
                  icon: Icons.pool_outlined,
                  label: 'Active classes',
                  value: '${snap.data?.length ?? '—'}',
                  route: '/classes',
                ),
              ),
              StreamBuilder(
                stream: membersAsync,
                builder: (context, snap) => _StatCard(
                  icon: Icons.people_outline,
                  label: 'Total members',
                  value: '${snap.data?.length ?? '—'}',
                  route: '/members',
                ),
              ),
              StreamBuilder(
                stream: waitlistAsync,
                builder: (context, snap) => _StatCard(
                  icon: Icons.hourglass_top_outlined,
                  label: 'Waitlisted bookings',
                  value: '${snap.data?.length ?? '—'}',
                  highlight: (snap.data?.length ?? 0) > 0,
                  route: '/requests',
                ),
              ),
              _StatCard(
                icon: Icons.event_available_outlined,
                label: "Today's bookings",
                value: statsAsync.when(
                  data: (s) => '${s.todaysBookings}',
                  loading: () => '—',
                  error: (_, _) => '!',
                ),
                route: '/calendar',
              ),
              _StatCard(
                icon: Icons.payments_outlined,
                label: 'Revenue this month',
                value: statsAsync.when(
                  data: (s) => '${s.revenueThisMonth.toStringAsFixed(0)} SAR',
                  loading: () => '—',
                  error: (_, _) => '!',
                ),
                route: '/reports',
              ),
              _StatCard(
                icon: Icons.event_note_outlined,
                label: 'Upcoming sessions (7d)',
                value: statsAsync.when(
                  data: (s) => '${s.upcomingSessions}',
                  loading: () => '—',
                  error: (_, _) => '!',
                ),
                route: '/calendar',
              ),
              _StatCard(
                icon: Icons.warning_amber_outlined,
                label: 'Full / near-full classes',
                value: statsAsync.when(
                  data: (s) => '${s.fullOrNearFullSessions}',
                  loading: () => '—',
                  error: (_, _) => '!',
                ),
                highlight: statsAsync.maybeWhen(data: (s) => s.fullOrNearFullSessions > 0, orElse: () => false),
                route: '/calendar',
              ),
              _StatCard(
                icon: Icons.schedule_outlined,
                label: 'Packages expiring soon',
                value: statsAsync.when(
                  data: (s) => '${s.expiringPackages}',
                  loading: () => '—',
                  error: (_, _) => '!',
                ),
                highlight: statsAsync.maybeWhen(data: (s) => s.expiringPackages > 0, orElse: () => false),
                route: '/members',
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Use the sidebar to manage classes, the booking calendar, banners, packages, and more. '
            'Every change here is live in the mobile app immediately — no release needed.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.label, required this.value, this.highlight = false, required this.route});

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

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
          width: context.isMobile ? double.infinity : 220,
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
