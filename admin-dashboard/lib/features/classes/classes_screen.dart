import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import 'class_form_dialog.dart';

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesStream = ref.watch(classesRepositoryProvider).watchClasses();

    return AdminPageScaffold(
      title: 'Classes',
      actions: [
        FilledButton.icon(
          onPressed: () => showClassFormDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add class'),
        ),
      ],
      body: StreamBuilder<List<SwimClass>>(
        stream: classesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
          final classes = snapshot.data!;
          if (classes.isEmpty) {
            return const Padding(padding: EdgeInsets.all(40), child: Text('No classes yet — add one to get started.'));
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
    return ListTile(
      title: Text(swimClass.title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('${swimClass.categories.map((c) => c.name).join(', ')} · ${swimClass.durationMinutes} min · ${swimClass.price.toStringAsFixed(0)} SAR'),
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
                  title: const Text('Delete class?'),
                  content: Text('This does not delete existing sessions for "${swimClass.title}".'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
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
