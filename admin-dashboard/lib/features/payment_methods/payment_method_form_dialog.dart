import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';
import '../../core/widgets/responsive_dialog.dart';

Future<void> showPaymentMethodFormDialog(BuildContext context, WidgetRef ref, {PaymentMethodConfig? existing}) {
  return showDialog(context: context, builder: (_) => _PaymentMethodFormDialog(existing: existing));
}

class _PaymentMethodFormDialog extends ConsumerStatefulWidget {
  const _PaymentMethodFormDialog({this.existing});
  final PaymentMethodConfig? existing;

  @override
  ConsumerState<_PaymentMethodFormDialog> createState() => _PaymentMethodFormDialogState();
}

class _PaymentMethodFormDialogState extends ConsumerState<_PaymentMethodFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameEnCtrl = TextEditingController(text: widget.existing?.nameEn);
  late final _nameArCtrl = TextEditingController(text: widget.existing?.nameAr);
  late bool _isActive = widget.existing?.isActive ?? true;
  bool _isSaving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final method = PaymentMethodConfig(
      id: widget.existing?.id ?? '',
      nameEn: _nameEnCtrl.text.trim(),
      nameAr: _nameArCtrl.text.trim(),
      order: widget.existing?.order ?? 0,
      isActive: _isActive,
    );
    final repo = ref.read(paymentMethodsRepositoryProvider);
    if (widget.existing == null) {
      await repo.create(method);
    } else {
      await repo.update(method);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialogShell(
      title: widget.existing == null ? 'Add payment method' : 'Edit payment method',
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
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                subtitle: const Text('Shown to customers at checkout'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
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

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
}
