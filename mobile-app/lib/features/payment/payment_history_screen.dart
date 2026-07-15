import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatting.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/enums.dart';
import '../auth/auth_controller.dart';
import '../../core/widgets/glass_app_bar.dart';

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
              return Card(
                child: ListTile(
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
                  onTap: payment.status == PaymentStatus.succeeded
                      ? () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.paymentHistoryDownloadReceipt)),
                          )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
