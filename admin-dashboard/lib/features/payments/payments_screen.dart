import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/page_scaffold.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsStream = ref.watch(transactionsRepositoryProvider).watchAll();

    return AdminPageScaffold(
      title: 'Payments & Reports',
      body: StreamBuilder<List<Payment>>(
        stream: transactionsStream,
        builder: (context, snapshot) {
          final payments = snapshot.data ?? [];
          final succeeded = payments.where((p) => p.status == PaymentStatus.succeeded).toList();
          final totalRevenue = succeeded.fold<double>(0, (sum, p) => sum + p.amount);
          final refunded = payments.where((p) => p.status == PaymentStatus.refunded).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _ReportStat(label: 'Total revenue', value: '${totalRevenue.toStringAsFixed(0)} SAR'),
                  _ReportStat(label: 'Successful transactions', value: '${succeeded.length}'),
                  _ReportStat(label: 'Refunded', value: '$refunded'),
                ],
              ),
              const SizedBox(height: 28),
              const Text('Recent transactions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 12),
              if (payments.isEmpty)
                const Padding(padding: EdgeInsets.all(24), child: Text('No transactions yet.'))
              else
                Card(
                  child: Column(
                    children: [
                      for (final payment in payments.take(100))
                        ListTile(
                          title: Text(payment.description),
                          subtitle: Text('${payment.method.name} · ${payment.createdAt.toString().split(' ').first}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${payment.amount.toStringAsFixed(0)} ${payment.currency}', style: const TextStyle(fontWeight: FontWeight.w800)),
                              const SizedBox(width: 12),
                              _StatusChip(status: payment.status),
                              if (payment.status == PaymentStatus.succeeded)
                                IconButton(
                                  icon: const Icon(Icons.undo_rounded, size: 18),
                                  tooltip: 'Refund',
                                  onPressed: () => ref.read(transactionsRepositoryProvider).refund(payment.id),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportStat extends StatelessWidget {
  const _ReportStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final PaymentStatus status;

  Color get _color {
    switch (status) {
      case PaymentStatus.succeeded:
        return AppColors.success;
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.refunded:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(status.name, style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
