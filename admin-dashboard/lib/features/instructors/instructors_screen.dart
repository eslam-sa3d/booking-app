import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/responsive_dialog.dart';
import '../../data/repositories/instructors_repository.dart';
import 'instructor_form_dialog.dart';

// Cached per-id so re-rebuilding the list (e.g. from an unrelated stream
// tick) doesn't re-issue a rating/class-lookup query for every row every
// time — Riverpod keeps one cached result per distinct id argument.
final _instructorRatingProvider = FutureProvider.family<InstructorRating, String>((ref, instructorId) {
  return ref.watch(instructorsRepositoryProvider).getComputedRating(instructorId);
});

final _classByIdProvider = FutureProvider.family<SwimClass?, String>((ref, classId) {
  return ref.watch(classesRepositoryProvider).getById(classId);
});

class InstructorsScreen extends ConsumerWidget {
  const InstructorsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Instructor instructor) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.instructorsDeleteTitle),
        content: Text(l10n.instructorsDeleteContent(instructor.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonDelete)),
        ],
      ),
    );
    if (confirmed == true) await ref.read(instructorsRepositoryProvider).delete(instructor.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final instructorsStream = ref.watch(instructorsRepositoryProvider).watchAll();

    return AdminPageScaffold(
      title: l10n.instructorsTitle,
      actions: [
        FilledButton.icon(
          onPressed: () => showInstructorFormDialog(context, ref),
          icon: const Icon(Icons.add),
          label: Text(l10n.instructorsAddButton),
        ),
      ],
      body: StreamBuilder<List<Instructor>>(
        stream: instructorsStream,
        builder: (context, snapshot) {
          final instructors = snapshot.data ?? [];
          if (instructors.isEmpty) {
            return Padding(padding: const EdgeInsets.all(40), child: Text(l10n.instructorsEmptyState));
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
                        Consumer(
                          builder: (context, ref, _) {
                            final ratingAsync = ref.watch(_instructorRatingProvider(instructor.id));
                            return Text(ratingAsync.when(
                              data: (r) => '★ ${r.display}',
                              loading: () => '…',
                              error: (_, _) => '—',
                            ));
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
                          tooltip: l10n.instructorsViewScheduleTooltip,
                          onPressed: () => _showSchedule(context, ref, instructor),
                        ),
                        IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => showInstructorFormDialog(context, ref, existing: instructor)),
                        IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _confirmDelete(context, ref, instructor)),
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
    final l10n = AppLocalizations.of(context)!;
    final sessionsStream = ref.watch(sessionsRepositoryProvider).watchForInstructor(instructor.id);

    return ResponsiveDialogShell(
      title: l10n.instructorScheduleTitle(instructor.name),
      desktopWidth: 460,
      desktopHeight: 480,
      content: StreamBuilder<List<SwimSession>>(
          stream: sessionsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final sessions = snapshot.data!;
            if (sessions.isEmpty) {
              return Center(child: Text(l10n.instructorScheduleEmptyState));
            }
            return ListView.separated(
              itemCount: sessions.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final session = sessions[index];
                return Consumer(
                  builder: (context, ref, _) {
                    final classAsync = ref.watch(_classByIdProvider(session.classId));
                    final title = classAsync.valueOrNull?.title ?? session.classId;
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
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonClose))],
    );
  }
}
