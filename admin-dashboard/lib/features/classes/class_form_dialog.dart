import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/responsive_dialog.dart';

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
  Set<String> _categories = {};
  String? _instructorId;
  String? _branchId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _categories = widget.existing?.categories.toSet() ?? {};
    _instructorId = widget.existing?.instructorId;
    _branchId = widget.existing?.branchId;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _categories.isEmpty || _instructorId == null || _branchId == null) {
      if (_categories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one category')));
      } else if (_instructorId == null || _branchId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select an instructor and branch')));
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
      instructorId: _instructorId!,
      branchId: _branchId!,
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
    final categoriesStream = ref.watch(categoriesRepositoryProvider).watchAll();
    final instructorsStream = ref.watch(instructorsRepositoryProvider).watchAll();
    final branchesStream = ref.watch(branchesRepositoryProvider).watchAll();

    return ResponsiveDialogShell(
      title: widget.existing == null ? 'Add class' : 'Edit class',
      desktopWidth: 480,
      content: Form(
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
                const Text('Categories', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                const SizedBox(height: 6),
                StreamBuilder<List<Category>>(
                  stream: categoriesStream,
                  builder: (context, snap) {
                    final categories = snap.data ?? const [];
                    return Wrap(
                      spacing: 8,
                      children: categories.map((c) {
                        final selected = _categories.contains(c.id);
                        return FilterChip(
                          label: Text(c.nameEn),
                          selected: selected,
                          onSelected: (v) => setState(() => v ? _categories.add(c.id) : _categories.remove(c.id)),
                        );
                      }).toList(),
                    );
                  },
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
                    Expanded(
                      child: StreamBuilder<List<Instructor>>(
                        stream: instructorsStream,
                        builder: (context, snap) {
                          final instructors = snap.data ?? const [];
                          return DropdownButtonFormField<String>(
                            initialValue: instructors.any((i) => i.id == _instructorId) ? _instructorId : null,
                            decoration: const InputDecoration(labelText: 'Instructor'),
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
                            decoration: const InputDecoration(labelText: 'Branch / Pool'),
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
              ],
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
