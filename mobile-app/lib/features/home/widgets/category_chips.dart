import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/locale_provider.dart';
import '../home_providers.dart';

class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);
    final isArabic = ref.watch(isArabicProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      data: (categories) => SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selected == category.id;
            return Semantics(
              label: category.localizedName(isArabic),
              selected: isSelected,
              button: true,
              child: ChoiceChip(
                label: Text(category.localizedName(isArabic)),
                selected: isSelected,
                onSelected: (_) {
                  ref.read(selectedCategoryProvider.notifier).state = isSelected ? null : category.id;
                },
              ),
            );
          },
        ),
      ),
      loading: () => const SizedBox(height: 40),
      error: (_, _) => const SizedBox(height: 40),
    );
  }
}
