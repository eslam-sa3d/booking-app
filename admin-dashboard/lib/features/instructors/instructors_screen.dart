import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import 'instructor_form_dialog.dart';

class InstructorsScreen extends ConsumerWidget {
  const InstructorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructorsStream = ref.watch(instructorsRepositoryProvider).watchAll();

    return AdminPageScaffold(
      title: 'Instructors',
      actions: [
        FilledButton.icon(
          onPressed: () => showInstructorFormDialog(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Add instructor'),
        ),
      ],
      body: StreamBuilder<List<Instructor>>(
        stream: instructorsStream,
        builder: (context, snapshot) {
          final instructors = snapshot.data ?? [];
          if (instructors.isEmpty) {
            return const Padding(padding: EdgeInsets.all(40), child: Text('No instructors yet.'));
          }
          return Card(
            child: Column(
              children: [
                for (final instructor in instructors)
                  ListTile(
                    leading: CircleAvatar(child: Text(instructor.initials)),
                    title: Text(instructor.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${instructor.specialties.join(', ')} · ★ ${instructor.rating}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => showInstructorFormDialog(context, ref, existing: instructor)),
                        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => ref.read(instructorsRepositoryProvider).delete(instructor.id)),
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
