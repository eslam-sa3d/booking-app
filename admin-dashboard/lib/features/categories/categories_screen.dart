import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import 'category_form_dialog.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesStream = ref.watch(categoriesRepositoryProvider).watchAll();

    return AdminPageScaffold(
      title: 'Categories',
      actions: [
        FilledButton.icon(
          onPressed: () => showCategoryFormDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add category'),
        ),
      ],
      body: StreamBuilder<List<Category>>(
        stream: categoriesStream,
        builder: (context, snapshot) {
          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const Padding(padding: EdgeInsets.all(40), child: Text('No categories yet — add one to let members filter classes.'));
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
                        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => ref.read(categoriesRepositoryProvider).delete(category.id)),
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
