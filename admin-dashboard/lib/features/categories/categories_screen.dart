import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import 'category_form_dialog.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Category category) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.categoriesDeleteTitle),
        content: Text(l10n.categoriesDeleteMessage(category.nameEn)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) await ref.read(categoriesRepositoryProvider).delete(category.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesStream = ref.watch(categoriesRepositoryProvider).watchAll();

    return AdminPageScaffold(
      title: l10n.categoriesTitle,
      actions: [
        FilledButton.icon(
          onPressed: () => showCategoryFormDialog(context, ref),
          icon: const Icon(Icons.add),
          label: Text(l10n.categoriesAddButton),
        ),
      ],
      body: StreamBuilder<List<Category>>(
        stream: categoriesStream,
        builder: (context, snapshot) {
          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return Padding(padding: const EdgeInsets.all(40), child: Text(l10n.categoriesEmptyState));
          }
          return Card(
            child: ReorderableListView(
              shrinkWrap: true,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex--;
                final reordered = [...categories];
                final item = reordered.removeAt(oldIndex);
                reordered.insert(newIndex, item);
                ref.read(categoriesRepositoryProvider).reorder(reordered);
              },
              children: [
                for (final category in categories)
                  ListTile(
                    key: ValueKey(category.id),
                    leading: const Icon(Icons.category_outlined, color: Colors.teal),
                    title: Text(category.nameEn, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(category.nameAr),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => showCategoryFormDialog(context, ref, existing: category)),
                        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _confirmDelete(context, ref, category)),
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
