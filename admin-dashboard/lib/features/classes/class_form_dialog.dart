import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';

Future<void> showClassFormDialog(BuildContext context, WidgetRef ref, {SwimClass? existing}) {
  return showDialog(
    context: context,
    builder: (_) => _ClassFormDialog(existing: existing),
  );
}

class _ClassFormDialog extends ConsumerStatefulWidget {
  const _ClassFormDialog({this.existing});
  final SwimClass? existing;

  @override
  ConsumerState<_ClassFormDialog> createState() => _ClassFormDialogState();
}

class _ClassFormDialogState extends ConsumerState<_ClassFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _titleCtrl = TextEditingController(text: widget.existing?.title);
  late final _titleArCtrl = TextEditingController(text: widget.existing?.titleAr);
  late final _descCtrl = TextEditingController(text: widget.existing?.description);
  late final _descArCtrl = TextEditingController(text: widget.existing?.descriptionAr);
  late final _priceCtrl = TextEditingController(text: widget.existing?.price.toString() ?? '');
  late final _durationCtrl = TextEditingController(text: widget.existing?.durationMinutes.toString() ?? '45');
  late final _instructorIdCtrl = TextEditingController(text: widget.existing?.instructorId);
  late final _branchIdCtrl = TextEditingController(text: widget.existing?.branchId);
  Set<ClassCategory> _categories = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _categories = widget.existing?.categories.toSet() ?? {};
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _categories.isEmpty) {
      if (_categories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one category')));
      }
      return;
    }
    setState(() => _isSaving = true);
    final repo = ref.read(classesRepositoryProvider);
    final swimClass = SwimClass(
      id: widget.existing?.id ?? '',
      title: _titleCtrl.text.trim(),
      titleAr: _titleArCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      descriptionAr: _descArCtrl.text.trim(),
      categories: _categories.toList(),
      durationMinutes: int.tryParse(_durationCtrl.text) ?? 45,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      instructorId: _instructorIdCtrl.text.trim(),
      branchId: _branchIdCtrl.text.trim(),
    );
    if (widget.existing == null) {
      await repo.create(swimClass);
    } else {
      await repo.update(swimClass);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add class' : 'Edit class'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title (EN)'), validator: _req)),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _titleArCtrl, decoration: const InputDecoration(labelText: 'Title (AR)'), validator: _req)),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description (EN)'), maxLines: 2),
                const SizedBox(height: 12),
                TextFormField(controller: _descArCtrl, decoration: const InputDecoration(labelText: 'Description (AR)'), maxLines: 2),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ClassCategory.values.map((c) {
                    final selected = _categories.contains(c);
                    return FilterChip(
                      label: Text(c.name),
                      selected: selected,
                      onSelected: (v) => setState(() => v ? _categories.add(c) : _categories.remove(c)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Price (SAR)'), keyboardType: TextInputType.number, validator: _req)),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _durationCtrl, decoration: const InputDecoration(labelText: 'Duration (min)'), keyboardType: TextInputType.number, validator: _req)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _instructorIdCtrl, decoration: const InputDecoration(labelText: 'Instructor ID'), validator: _req)),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _branchIdCtrl, decoration: const InputDecoration(labelText: 'Branch ID'), validator: _req)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _isSaving ? null : _save, child: Text(_isSaving ? 'Saving…' : 'Save')),
      ],
    );
  }

  String? _req(String? v) => (v == null || v.isEmpty) ? 'Required' : null;
}
