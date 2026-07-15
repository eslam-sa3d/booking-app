import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(classesRepositoryProvider).watchClasses();
    final membersAsync = ref.watch(membersRepositoryProvider).watchAll();
    final waitlistAsync = ref.read(bookingsRepositoryProvider).watchByStatus(BookingStatus.waitlisted);

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
                ),
              ),
              StreamBuilder(
                stream: membersAsync,
                builder: (context, snap) => _StatCard(
                  icon: Icons.people_outline,
                  label: 'Total members',
                  value: '${snap.data?.length ?? '—'}',
                ),
              ),
              StreamBuilder(
                stream: waitlistAsync,
                builder: (context, snap) => _StatCard(
                  icon: Icons.hourglass_top_outlined,
                  label: 'Waitlisted bookings',
                  value: '${snap.data?.length ?? '—'}',
                  highlight: (snap.data?.length ?? 0) > 0,
                ),
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
  const _StatCard({required this.icon, required this.label, required this.value, this.highlight = false});

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
    );
  }
}
