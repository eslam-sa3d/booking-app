import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/widgets/responsive_dialog.dart';

Future<void> showPackageFormDialog(
  BuildContext context,
  WidgetRef ref, {
  SwimPackage? existing,
}) {
  return showDialog(
    context: context,
    builder: (_) => _PackageFormDialog(existing: existing),
  );
}

class _PackageFormDialog extends ConsumerStatefulWidget {
  const _PackageFormDialog({this.existing});
  final SwimPackage? existing;

  @override
  ConsumerState<_PackageFormDialog> createState() => _PackageFormDialogState();
}

class _PackageFormDialogState extends ConsumerState<_PackageFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.existing?.name);
  late final _nameArCtrl = TextEditingController(text: widget.existing?.nameAr);
  late final _descCtrl = TextEditingController(
    text: widget.existing?.description,
  );
  late final _descArCtrl = TextEditingController(
    text: widget.existing?.descriptionAr,
  );
  late final _priceCtrl = TextEditingController(
    text: widget.existing?.price.toString(),
  );
  late final _validityCtrl = TextEditingController(
    text: widget.existing?.validityDays.toString() ?? '30',
  );
  late final _sessionCountCtrl = TextEditingController(
    text: widget.existing?.sessionCount?.toString() ?? '',
  );
  late PackageType _type = widget.existing?.type ?? PackageType.sessionPack;
  late bool _isPopular = widget.existing?.isPopular ?? false;
  bool _isSaving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final pkg = SwimPackage(
      id: widget.existing?.id ?? '',
      name: _nameCtrl.text.trim(),
      nameAr: _nameArCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      descriptionAr: _descArCtrl.text.trim(),
      type: _type,
      sessionCount: _type == PackageType.monthlyUnlimited
          ? null
          : int.tryParse(_sessionCountCtrl.text),
      validityDays: int.tryParse(_validityCtrl.text) ?? 30,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      isPopular: _isPopular,
    );
    try {
      final repo = ref.read(packagesRepositoryProvider);
      if (widget.existing == null) {
        await repo.create(pkg);
      } else {
        await repo.update(pkg);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.packageFormSaveFailed(error.toString()))),
        );
      }
    }
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty)
      ? AppLocalizations.of(context)!.commonRequired
      : null;

  String? _positiveNumber(String? v) {
    final parsed = double.tryParse(v ?? '');
    if (parsed == null || parsed <= 0) {
      return AppLocalizations.of(context)!.packageFormMustBePositive;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveDialogShell(
      title: widget.existing == null
          ? l10n.packagesAddPackageTitle
          : l10n.packagesEditPackageTitle,
      desktopWidth: 460,
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: l10n.packageFormNameEnLabel),
                validator: _req,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameArCtrl,
                decoration: InputDecoration(labelText: l10n.packageFormNameArLabel),
                validator: _req,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: l10n.packageFormDescriptionEnLabel,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descArCtrl,
                decoration: InputDecoration(
                  labelText: l10n.packageFormDescriptionArLabel,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PackageType>(
                initialValue: _type,
                decoration: InputDecoration(labelText: l10n.packageFormTypeLabel),
                items: PackageType.values
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_type != PackageType.monthlyUnlimited) ...[
                    Expanded(
                      child: TextFormField(
                        controller: _sessionCountCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.packageFormSessionCountLabel,
                        ),
                        keyboardType: TextInputType.number,
                        validator: _positiveNumber,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: TextFormField(
                      controller: _validityCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.packageFormValidityDaysLabel,
                      ),
                      keyboardType: TextInputType.number,
                      validator: _positiveNumber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: InputDecoration(labelText: l10n.packageFormPriceLabel),
                keyboardType: TextInputType.number,
                validator: _positiveNumber,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.packageFormMarkAsPopularLabel),
                value: _isPopular,
                onChanged: (v) => setState(() => _isPopular = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: Text(_isSaving ? l10n.commonSaving : l10n.commonSave),
        ),
      ],
    );
  }
}
