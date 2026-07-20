import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import 'banner_form_dialog.dart';

class BannersScreen extends ConsumerWidget {
  const BannersScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, PromoBanner banner) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.bannersDeleteTitle),
        content: Text(l10n.bannersDeleteMessage(banner.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) await ref.read(bannersRepositoryProvider).delete(banner.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final bannersStream = ref.watch(bannersRepositoryProvider).watchAll();

    return AdminPageScaffold(
      title: l10n.bannersTitle,
      actions: [
        FilledButton.icon(
          onPressed: () => showBannerFormDialog(context, ref),
          icon: const Icon(Icons.add),
          label: Text(l10n.bannersAddButton),
        ),
      ],
      body: StreamBuilder<List<PromoBanner>>(
        stream: bannersStream,
        builder: (context, snapshot) {
          final banners = snapshot.data ?? [];
          if (banners.isEmpty) {
            return Padding(padding: const EdgeInsets.all(40), child: Text(l10n.bannersEmptyState));
          }
          return Card(
            child: ReorderableListView(
              shrinkWrap: true,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;
                final reordered = [...banners];
                final item = reordered.removeAt(oldIndex);
                reordered.insert(newIndex, item);
                ref.read(bannersRepositoryProvider).reorder(reordered);
              },
              children: [
                for (final banner in banners)
                  ListTile(
                    key: ValueKey(banner.id),
                    leading: Icon(Icons.local_offer, color: banner.isActive ? Colors.teal : Colors.grey),
                    title: Text(banner.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(banner.subtitle),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!banner.isActive) Padding(padding: const EdgeInsetsDirectional.only(end: 8), child: Text(l10n.commonInactive, style: const TextStyle(color: Colors.grey))),
                        IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => showBannerFormDialog(context, ref, existing: banner)),
                        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _confirmDelete(context, ref, banner)),
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
