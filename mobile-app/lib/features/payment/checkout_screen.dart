import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/models.dart';
import '../auth/auth_controller.dart';
import '../packages/packages_providers.dart';
import '../../core/widgets/glass_app_bar.dart';
import 'payment_providers.dart';

enum _CheckoutStage { form, methodDetail, processing, success, pending, failed }

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.package});

  final SwimPackage package;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _methodId;
  PaymentMethodConfig? _selectedMethod;
  _CheckoutStage _stage = _CheckoutStage.form;
  String? _failureReason;

  @override
  void initState() {
    super.initState();
    // Fires for both a fresh purchase and a renewal — both funnel through
    // this same checkout flow, so this is "when renewal/purchase starts".
    ref.read(analyticsServiceProvider).logPackagePurchaseStarted(
          packageId: widget.package.id,
          amount: widget.package.price,
        );
  }

  // Methods admin configures with a payment link (bank transfer, external
  // gateway, etc.) route through the link-detail screen instead — there's no
  // way for the app to charge those directly, so checkout only fakes an
  // immediate charge for methods without one.
  Future<void> _pay() async {
    final method = _selectedMethod;
    if (method == null) return;

    final link = method.paymentLinkUrl;
    if (link != null && link.isNotEmpty) {
      setState(() => _stage = _CheckoutStage.methodDetail);
      return;
    }

    await _chargeDirectly(method);
  }

  Future<void> _chargeDirectly(PaymentMethodConfig method) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _stage = _CheckoutStage.processing);

    try {
      final result = await ref.read(paymentServiceProvider).charge(
            amount: widget.package.price,
            currency: widget.package.currency,
            method: method.id,
          );
      if (!mounted) return;

      // Transaction recording and package granting happen together
      // server-side (see purchasePackage Cloud Function) — firestore.rules
      // blocks a client from writing either directly.
      final outcome = await ref.read(packageRepositoryProvider).purchasePackage(
            userId: user.id,
            package: widget.package,
            method: method.id,
            status: result.success ? PaymentStatus.succeeded : PaymentStatus.failed,
            failureReason: result.failureReason,
          );

      await ref.read(analyticsServiceProvider).logPaymentCompleted(
            packageId: widget.package.id,
            amount: widget.package.price,
            success: outcome.success,
          );

      if (outcome.success) {
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _stage = _CheckoutStage.failed;
          _failureReason = null;
        });
      }
    }
  }

  // The app can't know whether an external payment actually went through —
  // it just opens the admin-configured link and records the attempt as
  // pending for later reconciliation (see PaymentHistoryScreen/admin Payments).
  Future<void> _confirmExternalPayment(PaymentMethodConfig method) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await _openPaymentLink(method.paymentLinkUrl!);
      if (!mounted) return;

      await ref.read(packageRepositoryProvider).purchasePackage(
            userId: user.id,
            package: widget.package,
            method: method.id,
            status: PaymentStatus.pending,
          );

      if (mounted) setState(() => _stage = _CheckoutStage.pending);
    } catch (e) {
      if (mounted) {
        setState(() {
          _stage = _CheckoutStage.failed;
          _failureReason = null;
        });
      }
    }
  }

  Future<void> _openPaymentLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
      case _CheckoutStage.methodDetail:
        final method = _selectedMethod!;
        return _PaymentLinkView(
          method: method,
          amount: widget.package.price,
          currency: widget.package.currency,
          isArabic: isArabic,
          l10n: l10n,
          onConfirm: () => _confirmExternalPayment(method),
          onBack: () => setState(() => _stage = _CheckoutStage.form),
        );
      case _CheckoutStage.pending:
        return _ResultView(
          icon: Icons.hourglass_top_rounded,
          color: AppColors.warning,
          title: l10n.checkoutPendingTitle,
          subtitle: l10n.checkoutPendingSubtitle,
          actionLabel: l10n.actionDone,
          onAction: () => context.go('/packages'),
        );
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
            Consumer(
              builder: (context, ref, _) {
                final methodsAsync = ref.watch(activePaymentMethodsProvider);
                return methodsAsync.when(
                  loading: () => const LoadingView(),
                  error: (_, _) => ErrorView(onRetry: () => ref.invalidate(activePaymentMethodsProvider)),
                  data: (methods) {
                    if (methods.isEmpty) {
                      return Text(l10n.checkoutNoPaymentMethods);
                    }
                    if (_methodId == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted && _methodId == null) {
                          setState(() {
                            _methodId = methods.first.id;
                            _selectedMethod = methods.first;
                          });
                        }
                      });
                    }
                    return RadioGroup<String>(
                      groupValue: _methodId,
                      onChanged: (v) => setState(() {
                        _methodId = v;
                        for (final m in methods) {
                          if (m.id == v) _selectedMethod = m;
                        }
                      }),
                      child: Column(
                        children: methods
                            .map(
                              (method) => RadioListTile<String>(
                                contentPadding: EdgeInsets.zero,
                                secondary: _MethodLogo(logoUrl: method.logoUrl),
                                title: Text(method.localizedName(isArabic)),
                                subtitle: method.paymentLinkUrl == null
                                    ? null
                                    : Align(
                                        alignment: AlignmentDirectional.centerStart,
                                        child: TextButton(
                                          onPressed: () => _openPaymentLink(method.paymentLinkUrl!),
                                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                          child: Text(l10n.checkoutPayNowLink),
                                        ),
                                      ),
                                value: method.id,
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                );
              },
            ),
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
            Semantics(
              button: true,
              label: l10n.checkoutPayNow('${widget.package.price.toStringAsFixed(0)} ${widget.package.currency}'),
              child: AppButton(
                label: l10n.checkoutPayNow('${widget.package.price.toStringAsFixed(0)} ${widget.package.currency}'),
                onPressed: _pay,
              ),
            ),
          ],
        );
    }
  }
}

class _MethodLogo extends StatelessWidget {
  const _MethodLogo({required this.logoUrl, this.size = 32});
  final String? logoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = logoUrl;
    if (url == null || url.isEmpty) {
      return Icon(Icons.payments_outlined, size: size);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(Icons.payments_outlined, size: size),
      ),
    );
  }
}

/// Shown after tapping the main checkout button when the selected payment
/// method has an admin-configured link (bank transfer, external gateway,
/// etc.) — the app can't charge those directly, so this surfaces the
/// method's own logo/branding and hands off to that external link.
class _PaymentLinkView extends StatelessWidget {
  const _PaymentLinkView({
    required this.method,
    required this.amount,
    required this.currency,
    required this.isArabic,
    required this.l10n,
    required this.onConfirm,
    required this.onBack,
  });

  final PaymentMethodConfig method;
  final double amount;
  final String currency;
  final bool isArabic;
  final AppLocalizations l10n;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(height: 12),
          Center(child: _MethodLogo(logoUrl: method.logoUrl, size: 88)),
          const SizedBox(height: 20),
          Text(
            method.localizedName(isArabic),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${amount.toStringAsFixed(0)} $currency',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.checkoutMethodDetailInstructions,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          Semantics(
            button: true,
            label: l10n.checkoutPayNowLink,
            child: AppButton(label: l10n.checkoutPayNowLink, onPressed: onConfirm),
          ),
        ],
      ),
    );
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
            SizedBox(width: double.infinity, child: AppButton(label: actionLabel, onPressed: onAction)),
          ],
        ),
      ),
    );
  }
}
