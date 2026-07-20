import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import 'class_form_dialog.dart';

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final classesStream = ref.watch(classesRepositoryProvider).watchClasses();

    return AdminPageScaffold(
      title: l10n.classesTitle,
      actions: [
        FilledButton.icon(
          onPressed: () => showClassFormDialog(context, ref),
          icon: const Icon(Icons.add),
          label: Text(l10n.classesAddButton),
        ),
      ],
      body: StreamBuilder<List<SwimClass>>(
        stream: classesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
          final classes = snapshot.data!;
          if (classes.isEmpty) {
            return Padding(padding: const EdgeInsets.all(40), child: Text(l10n.classesEmptyState));
          }
          return Card(
            child: Column(
              children: [
                for (final swimClass in classes) _ClassRow(swimClass: swimClass),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ClassRow extends ConsumerWidget {
  const _ClassRow({required this.swimClass});
  final SwimClass swimClass;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesStream = ref.watch(categoriesRepositoryProvider).watchAll();
    return ListTile(
      title: Text(swimClass.title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: StreamBuilder<List<Category>>(
        stream: categoriesStream,
        builder: (context, snap) {
          final byId = {for (final c in snap.data ?? const <Category>[]) c.id: c.nameEn};
          final names = swimClass.categories.map((id) => byId[id] ?? id).join(', ');
          return Text(l10n.classesRowSummary(names, swimClass.durationMinutes.toString(), swimClass.price.toStringAsFixed(0)));
        },
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => showClassFormDialog(context, ref, existing: swimClass)),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.classesDeleteTitle),
                  content: Text(l10n.classesDeleteContent(swimClass.title)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonDelete)),
                  ],
                ),
              );
              if (confirmed == true) await ref.read(classesRepositoryProvider).delete(swimClass.id);
            },
          ),
        ],
      ),
    );
  }
}
