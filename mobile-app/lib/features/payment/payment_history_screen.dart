import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatting.dart';
import '../../core/widgets/app_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/enums.dart';
import '../../data/models/payment.dart';
import '../auth/auth_controller.dart';
import '../../core/widgets/glass_app_bar.dart';
import 'receipt_screen.dart';

final paymentHistoryProvider = FutureProvider((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  return ref.watch(paymentRepositoryProvider).getPaymentHistory(user.id);
});

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  Color _statusColor(PaymentStatus status) {
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

  Future<void> _requestRefund(BuildContext context, WidgetRef ref, AppLocalizations l10n, Payment payment) async {
    final controller = TextEditingController();
    final reason = await showAppDialog<String>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.paymentHistoryRefundDialogTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(hintText: l10n.paymentHistoryRefundReasonHint),
            onChanged: (_) => setState(() {}),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.actionCancel)),
            TextButton(
              onPressed: controller.text.trim().isEmpty ? null : () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.paymentHistoryRefundSubmit),
            ),
          ],
        ),
      ),
    );
    if (reason == null || reason.isEmpty) return;
    await ref.read(paymentRepositoryProvider).requestRefund(payment.id, reason);
    ref.invalidate(paymentHistoryProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.paymentHistoryRefundSubmitted)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.watch(isArabicProvider);
    final locale = Localizations.localeOf(context).languageCode;
    final historyAsync = ref.watch(paymentHistoryProvider);

    return Scaffold(
      appBar: GlassAppBar(title: Text(l10n.paymentHistoryTitle)),
      body: historyAsync.when(
        loading: () => const LoadingView(),
        error: (_, _) => ErrorView(onRetry: () => ref.invalidate(paymentHistoryProvider)),
        data: (payments) {
          if (payments.isEmpty) {
            return EmptyState(icon: Icons.receipt_long_outlined, message: l10n.paymentHistoryEmpty);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: payments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final payment = payments[index];
              final color = _statusColor(payment.status);
              final refundPending = payment.refundRequestStatus == RefundRequestStatus.pending;
              final canRequestRefund = payment.status == PaymentStatus.succeeded && !refundPending;
              return Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(payment.localizedDescription(isArabic)),
                      subtitle: Text(
                        '${AppDateFormat.dayMonth(payment.createdAt, locale)} · ${payment.method.label(l10n)}',
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${payment.amount.toStringAsFixed(0)} ${payment.currency}', style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(payment.status.label(l10n), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ReceiptScreen(payment: payment)),
                      ),
                    ),
                    if (refundPending || canRequestRefund)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 12, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (refundPending)
                              Text(
                                l10n.paymentHistoryRefundPending,
                                style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            if (canRequestRefund)
                              Semantics(
                                button: true,
                                label: l10n.paymentHistoryRequestRefund,
                                child: TextButton(
                                  onPressed: () => _requestRefund(context, ref, l10n, payment),
                                  child: Text(l10n.paymentHistoryRequestRefund),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
