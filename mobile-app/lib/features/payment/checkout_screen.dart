import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/enum_localizations.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/models.dart';
import '../auth/auth_controller.dart';
import '../packages/packages_providers.dart';
import '../../core/widgets/glass_app_bar.dart';

enum _CheckoutStage { form, processing, success, failed }

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.package});

  final SwimPackage package;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  PaymentMethod _method = PaymentMethod.mada;
  _CheckoutStage _stage = _CheckoutStage.form;
  String? _failureReason;

  Future<void> _pay() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _stage = _CheckoutStage.processing);

    final result = await ref.read(paymentServiceProvider).charge(
          amount: widget.package.price,
          currency: widget.package.currency,
          method: _method,
        );

    if (!mounted) return;

    await ref.read(paymentRepositoryProvider).recordPayment(
          Payment(
            id: '',
            userId: user.id,
            amount: widget.package.price,
            currency: widget.package.currency,
            method: _method,
            status: result.success ? PaymentStatus.succeeded : PaymentStatus.failed,
            createdAt: DateTime.now(),
            description: '${widget.package.name} purchase',
            descriptionAr: 'شراء ${widget.package.nameAr}',
            relatedPackageId: widget.package.id,
          ),
        );

    if (result.success) {
      await ref.read(packageRepositoryProvider).purchasePackage(userId: user.id, packageId: widget.package.id);
      ref.invalidate(userPackagesProvider);
      if (mounted) setState(() => _stage = _CheckoutStage.success);
    } else {
      if (mounted) {
        setState(() {
          _stage = _CheckoutStage.failed;
          _failureReason = result.failureReason;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.watch(isArabicProvider);

    return Scaffold(
      appBar: GlassAppBar(title: Text(l10n.checkoutTitle)),
      body: SafeArea(child: _buildBody(context, l10n, isArabic)),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n, bool isArabic) {
    switch (_stage) {
      case _CheckoutStage.processing:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [const CircularProgressIndicator(), const SizedBox(height: 16), Text(l10n.checkoutProcessing)],
          ),
        );
      case _CheckoutStage.success:
        return _ResultView(
          icon: Icons.check_circle_rounded,
          color: AppColors.success,
          title: l10n.checkoutSuccessTitle,
          subtitle: l10n.checkoutSuccessSubtitle,
          actionLabel: l10n.actionDone,
          onAction: () => context.go('/packages'),
        );
      case _CheckoutStage.failed:
        return _ResultView(
          icon: Icons.error_rounded,
          color: AppColors.error,
          title: l10n.checkoutFailedTitle,
          subtitle: _failureReason ?? l10n.checkoutFailedSubtitle,
          actionLabel: l10n.actionRetry,
          onAction: () => setState(() => _stage = _CheckoutStage.form),
        );
      case _CheckoutStage.form:
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(l10n.checkoutOrderSummary, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(child: Text(widget.package.localizedName(isArabic), style: const TextStyle(fontWeight: FontWeight.w600))),
                    Text('${widget.package.price.toStringAsFixed(0)} ${widget.package.currency}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.checkoutPaymentMethod, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            ...PaymentMethod.values.map(
              (method) => RadioListTile<PaymentMethod>(
                contentPadding: EdgeInsets.zero,
                title: Text(method.label(l10n)),
                value: method,
                groupValue: _method,
                onChanged: (v) => setState(() => _method = v!),
              ),
            ),
            if (_method == PaymentMethod.creditCard) ...[
              const SizedBox(height: 8),
              TextField(decoration: InputDecoration(labelText: l10n.checkoutCardNumber), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(decoration: InputDecoration(labelText: l10n.checkoutCardExpiry))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(decoration: InputDecoration(labelText: l10n.checkoutCardCvv), obscureText: true)),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.checkoutSecureNotice,
                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: l10n.checkoutPayNow('${widget.package.price.toStringAsFixed(0)} ${widget.package.currency}'),
              onPressed: _pay,
            ),
          ],
        );
    }
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 72),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onAction, child: Text(actionLabel))),
          ],
        ),
      ),
    );
  }
}
