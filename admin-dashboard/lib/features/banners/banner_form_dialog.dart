import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
  late DateTime? _startDate = widget.existing?.startDate;
  late DateTime? _endDate = widget.existing?.endDate;
  bool _isSaving = false;

  final _dateFmt = DateFormat('MMM d, yyyy');

  PromoBanner _buildBanner() => PromoBanner(
        id: widget.existing?.id ?? '',
        title: _titleCtrl.text.trim(),
        titleAr: _titleArCtrl.text.trim(),
        subtitle: _subtitleCtrl.text.trim(),
        subtitleAr: _subtitleArCtrl.text.trim(),
        imageUrl: _imageUrlCtrl.text.trim(),
        linkAction: _linkCtrl.text.trim().isEmpty ? null : _linkCtrl.text.trim(),
        order: widget.existing?.order ?? 0,
        isActive: _isActive,
        startDate: _startDate,
        endDate: _endDate,
      );

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final banner = _buildBanner();
    final repo = ref.read(bannersRepositoryProvider);
    if (widget.existing == null) {
      await repo.create(banner);
    } else {
      await repo.update(banner);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = (isStart ? _startDate : _endDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _openPreview() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Preview'),
        content: SizedBox(
          width: 360,
          child: _BannerPreviewCard(banner: _buildBanner()),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  Widget _dateField({required String label, required DateTime? value, required bool isStart}) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _pickDate(isStart: isStart),
            child: InputDecorator(
              decoration: InputDecoration(labelText: label),
              child: Text(value == null ? 'No limit' : _dateFmt.format(value)),
            ),
          ),
        ),
        if (value != null)
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () => setState(() {
              if (isStart) {
                _startDate = null;
              } else {
                _endDate = null;
              }
            }),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add banner' : 'Edit banner'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
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
              const Align(alignment: Alignment.centerLeft, child: Text('Active date range (optional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: _dateField(label: 'Active from', value: _startDate, isStart: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _dateField(label: 'Active until', value: _endDate, isStart: false)),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _openPreview,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Preview'),
                ),
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
}

/// A simplified, static replica of the mobile app's banner carousel card
/// (see mobile-app/lib/features/home/widgets/banner_carousel.dart) so admins
/// can eyeball roughly how a banner will render before publishing it.
class _BannerPreviewCard extends StatelessWidget {
  const _BannerPreviewCard({required this.banner});
  final PromoBanner banner;

  static const _gradient = [Color(0xFF0EA5A4), Color(0xFF0A6E6D)];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 130,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: _gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (banner.imageUrl.isNotEmpty)
                  Image.network(
                    banner.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withValues(alpha: 0.15), Colors.transparent],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              banner.title.isEmpty ? 'Banner title' : banner.title,
                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              banner.subtitle.isEmpty ? 'Banner subtitle' : banner.subtitle,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.local_offer_rounded, color: Colors.white.withValues(alpha: 0.85), size: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          banner.isCurrentlyActive ? 'Would show now on the mobile home screen' : 'Would NOT show right now (inactive or outside date range)',
          style: TextStyle(fontSize: 12, color: banner.isCurrentlyActive ? Colors.teal : Colors.orange.shade800, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
