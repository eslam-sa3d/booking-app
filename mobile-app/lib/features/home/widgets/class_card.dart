import 'package:flutter/material.dart';

import '../../../core/widgets/class_hero_placeholder.dart';
import '../../../data/models/models.dart';

class ClassCard extends StatelessWidget {
  const ClassCard({
    super.key,
    required this.swimClass,
    required this.instructor,
    this.primaryCategory,
    required this.isArabic,
    required this.onTap,
  });

  final SwimClass swimClass;
  final Instructor? instructor;
  final Category? primaryCategory;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            ClassHeroPlaceholder(
              colorHex: swimClass.heroColorHex,
              iconName: swimClass.heroIcon,
              borderRadius: BorderRadius.zero,
              height: 96,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      swimClass.localizedTitle(isArabic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      instructor?.localizedName(isArabic) ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (primaryCategory != null) _MiniChip(label: primaryCategory!.localizedName(isArabic)),
                        _MiniChip(label: '${swimClass.price.toStringAsFixed(0)} ${swimClass.currency}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
