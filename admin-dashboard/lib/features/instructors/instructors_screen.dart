import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/responsive_dialog.dart';
import '../../data/repositories/instructors_repository.dart';
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
                    subtitle: Row(
                      children: [
                        Text('${instructor.specialties.join(', ')} · '),
                        FutureBuilder<InstructorRating>(
                          future: ref.read(instructorsRepositoryProvider).getComputedRating(instructor.id),
                          builder: (context, snap) {
                            if (!snap.hasData) return const Text('…');
                            return Text('★ ${snap.data!.display}');
                          },
                        ),
                      ],
                    ),
                    onTap: () => _showSchedule(context, ref, instructor),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.calendar_month_outlined),
                          tooltip: 'View schedule',
                          onPressed: () => _showSchedule(context, ref, instructor),
                        ),
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

  void _showSchedule(BuildContext context, WidgetRef ref, Instructor instructor) {
    showDialog(context: context, builder: (_) => _InstructorScheduleDialog(instructor: instructor));
  }
}

class _InstructorScheduleDialog extends ConsumerWidget {
  const _InstructorScheduleDialog({required this.instructor});
  final Instructor instructor;

  static final _dateFmt = DateFormat('EEE, MMM d, yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsStream = ref.watch(sessionsRepositoryProvider).watchForInstructor(instructor.id);

    return ResponsiveDialogShell(
      title: '${instructor.name} — upcoming sessions',
      desktopWidth: 460,
      desktopHeight: 480,
      content: StreamBuilder<List<SwimSession>>(
          stream: sessionsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final sessions = snapshot.data!;
            if (sessions.isEmpty) {
              return const Center(child: Text('No upcoming sessions.'));
            }
            return ListView.separated(
              itemCount: sessions.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final session = sessions[index];
                return FutureBuilder<SwimClass?>(
                  future: ref.read(classesRepositoryProvider).getById(session.classId),
                  builder: (context, classSnap) {
                    final title = classSnap.data?.title ?? session.classId;
                    return ListTile(
                      dense: true,
                      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${_dateFmt.format(session.date)} · ${session.formattedTimeRange()}'),
                      trailing: Text('${session.bookedCount}/${session.capacity}'),
                    );
                  },
                );
              },
            );
          },
        ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    );
  }
}
