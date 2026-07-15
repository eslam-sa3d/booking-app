import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waitlistStream = ref.watch(bookingsRepositoryProvider).watchByStatus(BookingStatus.waitlisted);
    final cancellationsStream = ref.watch(bookingsRepositoryProvider).watchRecentCancellations();

    return AdminPageScaffold(
      title: 'Requests',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Waitlisted bookings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 4),
          const Text(
            'Promotion is automatic when a confirmed booking is cancelled — this list is for visibility, not manual action.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Booking>>(
            stream: waitlistStream,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Padding(padding: EdgeInsets.only(bottom: 24), child: Text('No one is currently waitlisted.'));
              }
              return Card(
                margin: const EdgeInsets.only(bottom: 28),
                child: Column(
                  children: [
                    for (final booking in items)
                      ListTile(
                        title: Text(booking.participantName),
                        subtitle: Text('Session: ${booking.sessionId}'),
                        trailing: Text(booking.createdAt.toString().split(' ').first),
                      ),
                  ],
                ),
              );
            },
          ),
          const Text('Recent cancellations', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          StreamBuilder<List<Booking>>(
            stream: cancellationsStream,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Padding(padding: EdgeInsets.all(0), child: Text('No recent cancellations.'));
              }
              return Card(
                child: Column(
                  children: [
                    for (final booking in items)
                      ListTile(
                        title: Text(booking.participantName),
                        subtitle: Text(booking.cancellationReason?.isNotEmpty == true ? booking.cancellationReason! : 'No reason given'),
                        trailing: Text(booking.cancelledAt?.toString().split(' ').first ?? ''),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
