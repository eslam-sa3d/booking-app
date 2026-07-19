import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/responsive_dialog.dart';

Future<void> showCategoryFormDialog(BuildContext context, WidgetRef ref, {Category? existing}) {
  return showDialog(context: context, builder: (_) => _CategoryFormDialog(existing: existing));
}

class _CategoryFormDialog extends ConsumerStatefulWidget {
  const _CategoryFormDialog({this.existing});
  final Category? existing;

  @override
  ConsumerState<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameEnCtrl = TextEditingController(text: widget.existing?.nameEn);
  late final _nameArCtrl = TextEditingController(text: widget.existing?.nameAr);
  bool _isSaving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final category = Category(
      id: widget.existing?.id ?? '',
      nameEn: _nameEnCtrl.text.trim(),
      nameAr: _nameArCtrl.text.trim(),
      order: widget.existing?.order ?? 0,
    );
    try {
      final repo = ref.read(categoriesRepositoryProvider);
      if (widget.existing == null) {
        await repo.create(category);
      } else {
        await repo.update(category);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialogShell(
      title: widget.existing == null ? 'Add category' : 'Edit category',
      desktopWidth: 420,
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: _nameEnCtrl, decoration: const InputDecoration(labelText: 'Name (EN)'), validator: _req),
              const SizedBox(height: 12),
              TextFormField(controller: _nameArCtrl, decoration: const InputDecoration(labelText: 'Name (AR)'), validator: _req),
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

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
}
