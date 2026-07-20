import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';

class RequestsScreen extends ConsumerWidget {
  const RequestsScreen({super.key});

  Future<void> _resolveRefund(BuildContext context, WidgetRef ref, Payment payment, {required bool approve}) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(approve ? l10n.requestsApproveRefundTitle : l10n.requestsDenyRefundTitle),
        content: Text(
          approve ? l10n.requestsApproveRefundContent : l10n.requestsDenyRefundContent,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(approve ? l10n.requestsApproveButton : l10n.requestsDenyButton)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(transactionsRepositoryProvider).resolveRefundRequest(payment.id, approve: approve);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final waitlistStream = ref.watch(bookingsRepositoryProvider).watchByStatus(BookingStatus.waitlisted);
    final cancellationsStream = ref.watch(bookingsRepositoryProvider).watchRecentCancellations();
    final refundRequestsStream = ref.watch(transactionsRepositoryProvider).watchPendingRefundRequests();

    return AdminPageScaffold(
      title: l10n.requestsTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.requestsRefundRequestsHeading, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            l10n.requestsRefundRequestsSubtitle,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Payment>>(
            stream: refundRequestsStream,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return Padding(padding: const EdgeInsets.only(bottom: 28), child: Text(l10n.requestsNoPendingRefundRequests));
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
                            if (payment.refundRequestReason?.isNotEmpty == true)
                              payment.refundRequestReason!
                            else
                              l10n.requestsNoReasonGiven,
                            if (payment.refundRequestedAt != null)
                              l10n.requestsRequestedOn(payment.refundRequestedAt.toString().split(' ').first),
                          ].join(' · '),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => _resolveRefund(context, ref, payment, approve: false),
                              child: Text(l10n.requestsDenyButton),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _resolveRefund(context, ref, payment, approve: true),
                              child: Text(l10n.requestsApproveButton),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Text(l10n.requestsWaitlistedBookingsHeading, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            l10n.requestsWaitlistSubtitle,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Booking>>(
            stream: waitlistStream,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return Padding(padding: const EdgeInsets.only(bottom: 24), child: Text(l10n.requestsNoOneWaitlisted));
              }
              return Card(
                margin: const EdgeInsets.only(bottom: 28),
                child: Column(
                  children: [
                    for (final booking in items)
                      ListTile(
                        title: Text(booking.participantName),
                        subtitle: Text(l10n.requestsSessionLabel(booking.sessionId)),
                        trailing: Text(booking.createdAt.toString().split(' ').first),
                      ),
                  ],
                ),
              );
            },
          ),
          Text(l10n.requestsRecentCancellationsHeading, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          StreamBuilder<List<Booking>>(
            stream: cancellationsStream,
            builder: (context, snapshot) {
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return Padding(padding: EdgeInsets.zero, child: Text(l10n.requestsNoRecentCancellations));
              }
              return Card(
                child: Column(
                  children: [
                    for (final booking in items)
                      ListTile(
                        title: Text(booking.participantName),
                        subtitle: Text(
                          booking.cancellationReason?.isNotEmpty == true ? booking.cancellationReason! : l10n.requestsNoReasonGiven,
                        ),
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
