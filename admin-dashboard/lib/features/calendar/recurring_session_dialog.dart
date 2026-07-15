import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';

Future<void> showRecurringSessionDialog(BuildContext context, WidgetRef ref, {required List<SwimClass> classes}) {
  return showDialog(context: context, builder: (_) => _RecurringSessionDialog(classes: classes));
}

const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class _RecurringSessionDialog extends ConsumerStatefulWidget {
  const _RecurringSessionDialog({required this.classes});
  final List<SwimClass> classes;

  @override
  ConsumerState<_RecurringSessionDialog> createState() => _RecurringSessionDialogState();
}

class _RecurringSessionDialogState extends ConsumerState<_RecurringSessionDialog> {
  String? _classId;
  final Set<int> _weekdays = {};
  TimeOfDay _start = const TimeOfDay(hour: 16, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 17, minute: 0);
  final _capacityCtrl = TextEditingController(text: '10');
  DateTime _rangeStart = DateTime.now();
  DateTime _rangeEnd = DateTime.now().add(const Duration(days: 60));
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _classId = widget.classes.isNotEmpty ? widget.classes.first.id : null;
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _rangeStart : _rangeEnd,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() => isStart ? _rangeStart = picked : _rangeEnd = picked);
  }

  Future<void> _create() async {
    if (_classId == null || _weekdays.isEmpty) return;
    setState(() => _isSaving = true);
    final swimClass = widget.classes.firstWhere((c) => c.id == _classId);
    final count = await ref.read(sessionsRepositoryProvider).createRecurring(
          classId: _classId!,
          instructorId: swimClass.instructorId,
          branchId: swimClass.branchId,
          weekdays: _weekdays.toList(),
          startMinutes: _start.hour * 60 + _start.minute,
          endMinutes: _end.hour * 60 + _end.minute,
          capacity: int.tryParse(_capacityCtrl.text) ?? 10,
          start: _rangeStart,
          end: _rangeEnd,
        );
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Created $count sessions')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bulk-create recurring sessions'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _classId,
              decoration: const InputDecoration(labelText: 'Class'),
              items: widget.classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.title))).toList(),
              onChanged: (v) => setState(() => _classId = v),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: List.generate(7, (i) {
                final weekday = i + 1;
                final selected = _weekdays.contains(weekday);
                return FilterChip(
                  label: Text(_weekdayLabels[i]),
                  selected: selected,
                  onSelected: (v) => setState(() => v ? _weekdays.add(weekday) : _weekdays.remove(weekday)),
                );
              }),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => _pickDate(true), child: Text('From: ${_rangeStart.toString().split(' ').first}'))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton(onPressed: () => _pickDate(false), child: Text('To: ${_rangeEnd.toString().split(' ').first}'))),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: _isSaving || _classId == null || _weekdays.isEmpty ? null : _create,
          child: Text(_isSaving ? 'Creating…' : 'Create sessions'),
        ),
      ],
    );
  }
}
