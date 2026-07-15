import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers/repository_providers.dart';

Future<void> showBannerFormDialog(BuildContext context, WidgetRef ref, {PromoBanner? existing}) {
  return showDialog(context: context, builder: (_) => _BannerFormDialog(existing: existing));
}

class _BannerFormDialog extends ConsumerStatefulWidget {
  const _BannerFormDialog({this.existing});
  final PromoBanner? existing;

  @override
  ConsumerState<_BannerFormDialog> createState() => _BannerFormDialogState();
}

class _BannerFormDialogState extends ConsumerState<_BannerFormDialog> {
  late final _titleCtrl = TextEditingController(text: widget.existing?.title);
  late final _titleArCtrl = TextEditingController(text: widget.existing?.titleAr);
  late final _subtitleCtrl = TextEditingController(text: widget.existing?.subtitle);
  late final _subtitleArCtrl = TextEditingController(text: widget.existing?.subtitleAr);
  late final _imageUrlCtrl = TextEditingController(text: widget.existing?.imageUrl);
  late final _linkCtrl = TextEditingController(text: widget.existing?.linkAction);
  late bool _isActive = widget.existing?.isActive ?? true;
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final banner = PromoBanner(
      id: widget.existing?.id ?? '',
      title: _titleCtrl.text.trim(),
      titleAr: _titleArCtrl.text.trim(),
      subtitle: _subtitleCtrl.text.trim(),
      subtitleAr: _subtitleArCtrl.text.trim(),
      imageUrl: _imageUrlCtrl.text.trim(),
      linkAction: _linkCtrl.text.trim().isEmpty ? null : _linkCtrl.text.trim(),
      order: widget.existing?.order ?? 0,
      isActive: _isActive,
    );
    final repo = ref.read(bannersRepositoryProvider);
    if (widget.existing == null) {
      await repo.create(banner);
    } else {
      await repo.update(banner);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add banner' : 'Edit banner'),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title (EN)')),
            const SizedBox(height: 12),
            TextFormField(controller: _titleArCtrl, decoration: const InputDecoration(labelText: 'Title (AR)')),
            const SizedBox(height: 12),
            TextFormField(controller: _subtitleCtrl, decoration: const InputDecoration(labelText: 'Subtitle (EN)')),
            const SizedBox(height: 12),
            TextFormField(controller: _subtitleArCtrl, decoration: const InputDecoration(labelText: 'Subtitle (AR)')),
            const SizedBox(height: 12),
            TextFormField(controller: _imageUrlCtrl, decoration: const InputDecoration(labelText: 'Image URL')),
            const SizedBox(height: 12),
            TextFormField(controller: _linkCtrl, decoration: const InputDecoration(labelText: 'Link action (e.g. class:c1, packages)')),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
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
