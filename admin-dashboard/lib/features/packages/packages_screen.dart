import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import 'package_form_dialog.dart';

class PackagesScreen extends ConsumerWidget {
  const PackagesScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, SwimPackage pkg) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.packagesDeleteConfirmTitle),
        content: Text(l10n.packagesDeleteConfirmMessage(pkg.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) await ref.read(packagesRepositoryProvider).delete(pkg.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final packagesStream = ref.watch(packagesRepositoryProvider).watchAll();

    return AdminPageScaffold(
      title: l10n.packagesTitle,
      actions: [
        FilledButton.icon(
          onPressed: () => showPackageFormDialog(context, ref),
          icon: const Icon(Icons.add),
          label: Text(l10n.packagesAddPackageTitle),
        ),
      ],
      body: StreamBuilder<List<SwimPackage>>(
        stream: packagesStream,
        builder: (context, snapshot) {
          final packages = snapshot.data ?? [];
          if (packages.isEmpty) {
            return Padding(padding: const EdgeInsets.all(40), child: Text(l10n.packagesEmptyState));
          }
          return Card(
            child: Column(
              children: [
                for (final pkg in packages)
                  ListTile(
                    title: Row(children: [
                      Text(pkg.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      if (pkg.isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(20)),
                          child: Text(l10n.packagesPopularBadge, style: const TextStyle(fontSize: 11, color: Colors.teal)),
                        ),
                      ],
                    ]),
                    subtitle: Text(
                      '${pkg.type.name} · '
                      '${pkg.sessionCount != null ? l10n.packagesSessionsCount(pkg.sessionCount!) : l10n.packagesUnlimitedLabel} · '
                      '${l10n.packagesDaysCount(pkg.validityDays)} · '
                      '${l10n.packagesPriceEgp(pkg.price.toStringAsFixed(0))}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => showPackageFormDialog(context, ref, existing: pkg)),
                        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _confirmDelete(context, ref, pkg)),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
