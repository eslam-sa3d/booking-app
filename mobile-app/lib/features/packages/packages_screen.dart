import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../data/models/models.dart';
import '../auth/auth_controller.dart';
import 'packages_providers.dart';
import '../../core/widgets/glass_app_bar.dart';

class PackagesScreen extends ConsumerWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.watch(isArabicProvider);
    final user = ref.watch(currentUserProvider);
    final userPackagesAsync = ref.watch(userPackagesProvider);
    final availableAsync = ref.watch(availablePackagesProvider);
    final catalog = availableAsync.value ?? const <SwimPackage>[];

    return Scaffold(
      appBar: GlassAppBar(title: Text(l10n.packagesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null) ...[
            Text(l10n.packagesMyPackages, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            userPackagesAsync.when(
              loading: () => const LoadingView(),
              error: (_, _) => ErrorView(onRetry: () => ref.invalidate(userPackagesProvider)),
              data: (userPackages) {
                final active = userPackages.where((p) => !p.isExpired).toList();
                if (active.isEmpty) {
                  return EmptyState(icon: Icons.card_membership_outlined, message: l10n.packagesNoneActive);
                }
                return Column(
                  children: active.map((up) {
                    SwimPackage? pkg;
                    for (final c in catalog) {
                      if (c.id == up.packageId) pkg = c;
                    }
                    if (pkg == null) return const SizedBox.shrink();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pkg.localizedName(isArabic), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 6),
                            Text(
                              up.sessionsRemaining != null
                                  ? l10n.packagesSessionsLeft(up.sessionsRemaining!)
                                  : l10n.packagesUnlimited,
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.packagesExpiresIn(up.daysLeft),
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
          Text(l10n.packagesAvailable, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          availableAsync.when(
            loading: () => const LoadingView(),
            error: (_, _) => ErrorView(onRetry: () => ref.invalidate(availablePackagesProvider)),
            data: (packages) => Column(
              children: packages.map((pkg) => _PackageCard(pkg: pkg, isArabic: isArabic)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.pkg, required this.isArabic});

  final SwimPackage pkg;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: pkg.isPopular ? AppColors.primary : Theme.of(context).dividerColor, width: pkg.isPopular ? 1.5 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pkg.isPopular)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(l10n.packagesPopular, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 11)),
                ),
              ),
            Text(pkg.localizedName(isArabic), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(pkg.localizedDescription(isArabic), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 10),
            Text(l10n.packagesValidFor(pkg.validityDays), style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '${pkg.price.toStringAsFixed(0)} ${pkg.currency}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => context.push('/checkout', extra: pkg),
                  child: Text(l10n.packagesPurchase),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
