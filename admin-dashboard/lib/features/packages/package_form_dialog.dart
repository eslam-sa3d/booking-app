import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/responsive_dialog.dart';

Future<void> showPackageFormDialog(BuildContext context, WidgetRef ref, {SwimPackage? existing}) {
  return showDialog(context: context, builder: (_) => _PackageFormDialog(existing: existing));
}

class _PackageFormDialog extends ConsumerStatefulWidget {
  const _PackageFormDialog({this.existing});
  final SwimPackage? existing;

  @override
  ConsumerState<_PackageFormDialog> createState() => _PackageFormDialogState();
}

class _PackageFormDialogState extends ConsumerState<_PackageFormDialog> {
  late final _nameCtrl = TextEditingController(text: widget.existing?.name);
  late final _nameArCtrl = TextEditingController(text: widget.existing?.nameAr);
  late final _descCtrl = TextEditingController(text: widget.existing?.description);
  late final _descArCtrl = TextEditingController(text: widget.existing?.descriptionAr);
  late final _priceCtrl = TextEditingController(text: widget.existing?.price.toString());
  late final _validityCtrl = TextEditingController(text: widget.existing?.validityDays.toString() ?? '30');
  late final _sessionCountCtrl = TextEditingController(text: widget.existing?.sessionCount?.toString() ?? '');
  late PackageType _type = widget.existing?.type ?? PackageType.sessionPack;
  late bool _isPopular = widget.existing?.isPopular ?? false;
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final pkg = SwimPackage(
      id: widget.existing?.id ?? '',
      name: _nameCtrl.text.trim(),
      nameAr: _nameArCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      descriptionAr: _descArCtrl.text.trim(),
      type: _type,
      sessionCount: _type == PackageType.monthlyUnlimited ? null : int.tryParse(_sessionCountCtrl.text),
      validityDays: int.tryParse(_validityCtrl.text) ?? 30,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      isPopular: _isPopular,
    );
    final repo = ref.read(packagesRepositoryProvider);
    if (widget.existing == null) {
      await repo.create(pkg);
    } else {
      await repo.update(pkg);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialogShell(
      title: widget.existing == null ? 'Add package' : 'Edit package',
      desktopWidth: 460,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name (EN)')),
            const SizedBox(height: 12),
            TextFormField(controller: _nameArCtrl, decoration: const InputDecoration(labelText: 'Name (AR)')),
            const SizedBox(height: 12),
            TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description (EN)'), maxLines: 2),
            const SizedBox(height: 12),
            TextFormField(controller: _descArCtrl, decoration: const InputDecoration(labelText: 'Description (AR)'), maxLines: 2),
            const SizedBox(height: 12),
            DropdownButtonFormField<PackageType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: PackageType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (_type != PackageType.monthlyUnlimited) ...[
                  Expanded(child: TextFormField(controller: _sessionCountCtrl, decoration: const InputDecoration(labelText: 'Session count'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                ],
                Expanded(child: TextFormField(controller: _validityCtrl, decoration: const InputDecoration(labelText: 'Validity (days)'), keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Price (EGP)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mark as popular'),
              value: _isPopular,
              onChanged: (v) => setState(() => _isPopular = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _isSaving ? null : _save, child: Text(_isSaving ? 'Saving…' : 'Save')),
      ],
    );
  }
}
