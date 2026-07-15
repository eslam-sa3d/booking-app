import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/enum_localizations.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../data/models/models.dart';

/// Read-only, share-able view of a single transaction. Reused wherever a
/// user wants to look back at a past payment — currently only linked from
/// [PaymentHistoryScreen], replacing what used to be a "download receipt"
/// stub SnackBar.
class ReceiptScreen extends ConsumerWidget {
  const ReceiptScreen({super.key, required this.payment});

  final Payment payment;

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

  Future<void> _share(BuildContext context, AppLocalizations l10n, bool isArabic, String locale) async {
    final number = payment.receiptNumber ?? payment.id;
    final dateStr = DateFormat.yMMMMd(locale).add_jm().format(payment.createdAt);
    final body = '''
${l10n.paymentHistoryReceiptTitle}
${l10n.receiptTransactionId}: $number
${l10n.receiptDate}: $dateStr
${l10n.receiptDescription}: ${payment.localizedDescription(isArabic)}
${l10n.receiptAmount}: ${payment.amount.toStringAsFixed(2)} ${payment.currency}
${l10n.receiptMethod}: ${payment.method.label(l10n)}
${l10n.receiptStatus}: ${payment.status.label(l10n)}
''';
    // No dedicated share package is present in pubspec.yaml; mailto: via
    // url_launcher (already a dependency) is used as a plain-text share
    // fallback rather than adding a new dependency.
    final uri = Uri(
      scheme: 'mailto',
      queryParameters: {'subject': '${l10n.paymentHistoryReceiptTitle} $number', 'body': body},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.watch(isArabicProvider);
    final locale = Localizations.localeOf(context).languageCode;
    final color = _statusColor(payment.status);
    final number = payment.receiptNumber ?? payment.id;
    final dateStr = DateFormat.yMMMMd(locale).add_jm().format(payment.createdAt);

    return Scaffold(
      appBar: GlassAppBar(
        title: Text(l10n.paymentHistoryReceiptTitle),
        actions: [
          Semantics(
            button: true,
            label: l10n.receiptShare,
            child: IconButton(
              icon: const Icon(Icons.ios_share_rounded),
              onPressed: () => _share(context, l10n, isArabic, locale),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.receipt_long_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            payment.status.label(l10n),
                            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${payment.amount.toStringAsFixed(2)} ${payment.currency}',
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(payment.localizedDescription(isArabic), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
                    _ReceiptRow(label: l10n.receiptTransactionId, value: number),
                    _ReceiptRow(label: l10n.receiptDate, value: dateStr),
                    _ReceiptRow(label: l10n.receiptDescription, value: payment.localizedDescription(isArabic)),
                    _ReceiptRow(label: l10n.receiptMethod, value: payment.method.label(l10n)),
                    _ReceiptRow(label: l10n.receiptAmount, value: '${payment.amount.toStringAsFixed(2)} ${payment.currency}'),
                    _ReceiptRow(label: l10n.receiptStatus, value: payment.status.label(l10n)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
