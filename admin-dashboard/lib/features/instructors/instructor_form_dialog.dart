import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/widgets/responsive_dialog.dart';

Future<void> showInstructorFormDialog(BuildContext context, WidgetRef ref, {Instructor? existing}) {
  return showDialog(context: context, builder: (_) => _InstructorFormDialog(existing: existing));
}

class _InstructorFormDialog extends ConsumerStatefulWidget {
  const _InstructorFormDialog({this.existing});
  final Instructor? existing;

  @override
  ConsumerState<_InstructorFormDialog> createState() => _InstructorFormDialogState();
}

class _InstructorFormDialogState extends ConsumerState<_InstructorFormDialog> {
  late final _nameCtrl = TextEditingController(text: widget.existing?.name);
  late final _nameArCtrl = TextEditingController(text: widget.existing?.nameAr);
  late final _bioCtrl = TextEditingController(text: widget.existing?.bio);
  late final _bioArCtrl = TextEditingController(text: widget.existing?.bioAr);
  late final _specialtiesCtrl = TextEditingController(text: widget.existing?.specialties.join(', '));
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final instructor = Instructor(
      id: widget.existing?.id ?? '',
      name: _nameCtrl.text.trim(),
      nameAr: _nameArCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      bioAr: _bioArCtrl.text.trim(),
      specialties: _specialtiesCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
    );
    try {
      final repo = ref.read(instructorsRepositoryProvider);
      if (widget.existing == null) {
        await repo.create(instructor);
      } else {
        await repo.update(instructor);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.instructorFormSaveError(error.toString()))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveDialogShell(
      title: widget.existing == null ? l10n.instructorsAddButton : l10n.instructorFormEditTitle,
      desktopWidth: 460,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _nameCtrl, decoration: InputDecoration(labelText: l10n.instructorFormNameEnLabel)),
            const SizedBox(height: 12),
            TextFormField(controller: _nameArCtrl, decoration: InputDecoration(labelText: l10n.instructorFormNameArLabel)),
            const SizedBox(height: 12),
            TextFormField(controller: _bioCtrl, decoration: InputDecoration(labelText: l10n.instructorFormBioEnLabel), maxLines: 2),
            const SizedBox(height: 12),
            TextFormField(controller: _bioArCtrl, decoration: InputDecoration(labelText: l10n.instructorFormBioArLabel), maxLines: 2),
            const SizedBox(height: 12),
            TextFormField(controller: _specialtiesCtrl, decoration: InputDecoration(labelText: l10n.instructorFormSpecialtiesLabel)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonCancel)),
        FilledButton(onPressed: _isSaving ? null : _save, child: Text(_isSaving ? l10n.commonSaving : l10n.commonSave)),
      ],
    );
  }
}
