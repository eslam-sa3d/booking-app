import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/widgets/responsive_dialog.dart';

Future<void> showSessionFormDialog(
  BuildContext context,
  WidgetRef ref, {
  required DateTime date,
  required List<SwimClass> classes,
  SwimSession? existing,
}) {
  return showDialog(
    context: context,
    builder: (_) => _SessionFormDialog(date: date, classes: classes, existing: existing),
  );
}

class _SessionFormDialog extends ConsumerStatefulWidget {
  const _SessionFormDialog({required this.date, required this.classes, this.existing});
  final DateTime date;
  final List<SwimClass> classes;
  final SwimSession? existing;

  @override
  ConsumerState<_SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends ConsumerState<_SessionFormDialog> {
  String? _classId;
  String? _instructorId;
  String? _branchId;
  TimeOfDay _start = const TimeOfDay(hour: 16, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 17, minute: 0);
  late final _capacityCtrl = TextEditingController(text: widget.existing?.capacity.toString() ?? '10');
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _classId = widget.existing?.classId ?? (widget.classes.isNotEmpty ? widget.classes.first.id : null);
    if (widget.existing != null) {
      _start = TimeOfDay(hour: widget.existing!.startMinutes ~/ 60, minute: widget.existing!.startMinutes % 60);
      _end = TimeOfDay(hour: widget.existing!.endMinutes ~/ 60, minute: widget.existing!.endMinutes % 60);
      _instructorId = widget.existing!.instructorId;
      _branchId = widget.existing!.branchId;
    } else if (_classId != null) {
      final swimClass = widget.classes.firstWhere((c) => c.id == _classId);
      _instructorId = swimClass.instructorId;
      _branchId = swimClass.branchId;
    }
  }

  Future<void> _save() async {
    if (_classId == null || _instructorId == null || _branchId == null) return;
    setState(() => _isSaving = true);
    final session = SwimSession(
      id: widget.existing?.id ?? '',
      classId: _classId!,
      date: widget.date,
      startMinutes: _start.hour * 60 + _start.minute,
      endMinutes: _end.hour * 60 + _end.minute,
      capacity: int.tryParse(_capacityCtrl.text) ?? 10,
      bookedCount: widget.existing?.bookedCount ?? 0,
      waitlistCount: widget.existing?.waitlistCount ?? 0,
      instructorId: _instructorId!,
      branchId: _branchId!,
    );
    try {
      final repo = ref.read(sessionsRepositoryProvider);
      if (widget.existing == null) {
        await repo.create(session);
      } else {
        await repo.update(session);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.sessionFormSaveFailed(error.toString()))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final instructorsStream = ref.watch(instructorsRepositoryProvider).watchAll();
    final branchesStream = ref.watch(branchesRepositoryProvider).watchAll();

    return ResponsiveDialogShell(
      title: widget.existing == null ? l10n.calendarAddSession : l10n.sessionFormEditTitle,
      desktopWidth: 420,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _classId,
              decoration: InputDecoration(labelText: l10n.sessionFormClassLabel),
              items: widget.classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.title))).toList(),
              onChanged: (v) {
                setState(() {
                  _classId = v;
                  if (v != null && widget.existing == null) {
                    // Re-default instructor/branch to the newly selected class,
                    // unless editing an existing session (preserve its override).
                    final swimClass = widget.classes.firstWhere((c) => c.id == v);
                    _instructorId = swimClass.instructorId;
                    _branchId = swimClass.branchId;
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<List<Instructor>>(
                    stream: instructorsStream,
                    builder: (context, snap) {
                      final instructors = snap.data ?? const [];
                      return DropdownButtonFormField<String>(
                        initialValue: instructors.any((i) => i.id == _instructorId) ? _instructorId : null,
                        decoration: InputDecoration(labelText: l10n.sessionFormInstructorLabel),
                        items: [
                          for (final i in instructors) DropdownMenuItem(value: i.id, child: Text(i.name)),
                        ],
                        onChanged: (v) => setState(() => _instructorId = v),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder<List<Branch>>(
                    stream: branchesStream,
                    builder: (context, snap) {
                      final branches = snap.data ?? const [];
                      return DropdownButtonFormField<String>(
                        initialValue: branches.any((b) => b.id == _branchId) ? _branchId : null,
                        decoration: InputDecoration(labelText: l10n.sessionFormBranchPoolLabel),
                        items: [
                          for (final b in branches) DropdownMenuItem(value: b.id, child: Text(b.name)),
                        ],
                        onChanged: (v) => setState(() => _branchId = v),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showTimePicker(context: context, initialTime: _start);
                      if (picked != null) setState(() => _start = picked);
                    },
                    child: Text(l10n.sessionFormStartLabel(_start.format(context))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showTimePicker(context: context, initialTime: _end);
                      if (picked != null) setState(() => _end = picked);
                    },
                    child: Text(l10n.sessionFormEndLabel(_end.format(context))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _capacityCtrl, decoration: InputDecoration(labelText: l10n.sessionFormCapacityLabel), keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(
          onPressed: _isSaving || _classId == null || _instructorId == null || _branchId == null ? null : _save,
          child: Text(_isSaving ? l10n.commonSaving : l10n.commonSave),
        ),
      ],
    );
  }
}
