import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';

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
    }
  }

  Future<void> _save() async {
    if (_classId == null) return;
    setState(() => _isSaving = true);
    final swimClass = widget.classes.firstWhere((c) => c.id == _classId);
    final repo = ref.read(sessionsRepositoryProvider);
    final session = SwimSession(
      id: widget.existing?.id ?? '',
      classId: _classId!,
      date: widget.date,
      startMinutes: _start.hour * 60 + _start.minute,
      endMinutes: _end.hour * 60 + _end.minute,
      capacity: int.tryParse(_capacityCtrl.text) ?? 10,
      bookedCount: widget.existing?.bookedCount ?? 0,
      waitlistCount: widget.existing?.waitlistCount ?? 0,
      instructorId: swimClass.instructorId,
      branchId: swimClass.branchId,
    );
    if (widget.existing == null) {
      await repo.create(session);
    } else {
      await repo.update(session);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add session' : 'Edit session'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _classId,
              decoration: const InputDecoration(labelText: 'Class'),
              items: widget.classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.title))).toList(),
              onChanged: (v) => setState(() => _classId = v),
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
                    child: Text('Start: ${_start.format(context)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final picked = await showTimePicker(context: context, initialTime: _end);
                      if (picked != null) setState(() => _end = picked);
                    },
                    child: Text('End: ${_end.format(context)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _capacityCtrl, decoration: const InputDecoration(labelText: 'Capacity'), keyboardType: TextInputType.number),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _isSaving || _classId == null ? null : _save, child: Text(_isSaving ? 'Saving…' : 'Save')),
      ],
    );
  }
}
