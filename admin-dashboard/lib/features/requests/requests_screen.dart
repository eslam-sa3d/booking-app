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
    final refundRequestsStream = ref.watch(transactionsRepositoryProvider).watchPendingRefundRequests();

    return AdminPageScaffold(
      title: 'Requests',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Refund requests', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 4),
          const Text(
            'Customer-initiated refund requests awaiting a decision.',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Payment>>(
            stream: refundRequestsStream,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Padding(padding: EdgeInsets.only(bottom: 28), child: Text('No pending refund requests.'));
              }
              return Card(
                margin: const EdgeInsets.only(bottom: 28),
                child: Column(
                  children: [
                    for (final payment in items)
                      ListTile(
                        title: Text('${payment.amount.toStringAsFixed(0)} ${payment.currency} — ${_shortId(payment.userId)}'),
                        subtitle: Text(
                          [
                            if (payment.refundRequestReason?.isNotEmpty == true) payment.refundRequestReason! else 'No reason given',
                            if (payment.refundRequestedAt != null)
                              'Requested ${payment.refundRequestedAt.toString().split(' ').first}',
                          ].join(' · '),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  ref.read(transactionsRepositoryProvider).resolveRefundRequest(payment.id, approve: false),
                              child: const Text('Deny'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () =>
                                  ref.read(transactionsRepositoryProvider).resolveRefundRequest(payment.id, approve: true),
                              child: const Text('Approve'),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
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

/// A user-friendly, truncated form of a userId for display where looking up
/// the full member record isn't worth an extra query (e.g. a short list of
/// pending refund requests).
String _shortId(String userId) => userId.length <= 8 ? userId : '${userId.substring(0, 8)}…';
