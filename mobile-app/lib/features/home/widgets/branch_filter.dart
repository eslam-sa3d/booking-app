import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/locale_provider.dart';
import '../home_providers.dart';

/// Branch/pool filter chips for the Home class list — mirrors
/// [CategoryChips]' interaction model (tap to select, tap again to clear).
class BranchFilterChips extends ConsumerWidget {
  const BranchFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedBranchProvider);
    final isArabic = ref.watch(isArabicProvider);
    final branchesAsync = ref.watch(branchesProvider);

    return branchesAsync.when(
      data: (branches) {
        if (branches.length < 2) return const SizedBox.shrink();
        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: branches.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final branch = branches[index];
              final isSelected = selected == branch.id;
              return Semantics(
                label: branch.localizedName(isArabic),
                selected: isSelected,
                button: true,
                child: ChoiceChip(
                  avatar: const Icon(Icons.pool_rounded, size: 16),
                  label: Text(branch.localizedName(isArabic)),
                  selected: isSelected,
                  onSelected: (_) {
                    ref.read(selectedBranchProvider.notifier).state = isSelected ? null : branch.id;
                  },
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
