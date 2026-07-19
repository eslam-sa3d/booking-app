import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import 'banner_form_dialog.dart';

class BannersScreen extends ConsumerWidget {
  const BannersScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, PromoBanner banner) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete banner?'),
        content: Text('"${banner.title}" will be removed from the mobile home screen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) await ref.read(bannersRepositoryProvider).delete(banner.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersStream = ref.watch(bannersRepositoryProvider).watchAll();

    return AdminPageScaffold(
      title: 'Banners',
      actions: [
        FilledButton.icon(
          onPressed: () => showBannerFormDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add banner'),
        ),
      ],
      body: StreamBuilder<List<PromoBanner>>(
        stream: bannersStream,
        builder: (context, snapshot) {
          final banners = snapshot.data ?? [];
          if (banners.isEmpty) {
            return const Padding(padding: EdgeInsets.all(40), child: Text('No banners yet — the mobile home screen will show none until you add one.'));
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
                        if (!banner.isActive) const Padding(padding: EdgeInsets.only(right: 8), child: Text('Inactive', style: TextStyle(color: Colors.grey))),
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
