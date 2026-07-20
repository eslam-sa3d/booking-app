import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/widgets/responsive_dialog.dart';

Future<void> showBannerFormDialog(
  BuildContext context,
  WidgetRef ref, {
  PromoBanner? existing,
}) {
  return showDialog(
    context: context,
    builder: (_) => _BannerFormDialog(existing: existing),
  );
}

class _BannerFormDialog extends ConsumerStatefulWidget {
  const _BannerFormDialog({this.existing});
  final PromoBanner? existing;

  @override
  ConsumerState<_BannerFormDialog> createState() => _BannerFormDialogState();
}

class _BannerFormDialogState extends ConsumerState<_BannerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _titleCtrl = TextEditingController(text: widget.existing?.title);
  late final _titleArCtrl = TextEditingController(
    text: widget.existing?.titleAr,
  );
  late final _subtitleCtrl = TextEditingController(
    text: widget.existing?.subtitle,
  );
  late final _subtitleArCtrl = TextEditingController(
    text: widget.existing?.subtitleAr,
  );
  late final _imageUrlCtrl = TextEditingController(
    text: widget.existing?.imageUrl,
  );
  late final _linkCtrl = TextEditingController(
    text: widget.existing?.linkAction,
  );
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final banner = _buildBanner();
    try {
      final repo = ref.read(bannersRepositoryProvider);
      if (widget.existing == null) {
        await repo.create(banner);
      } else {
        await repo.update(banner);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.bannersSaveFailed('$error'),
            ),
          ),
        );
      }
    }
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty)
      ? AppLocalizations.of(context)!.commonRequired
      : null;

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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.bannersPreviewLabel),
        content: SizedBox(
          width: 360,
          child: _BannerPreviewCard(banner: _buildBanner()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonClose),
          ),
        ],
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required bool isStart,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _pickDate(isStart: isStart),
            child: InputDecorator(
              decoration: InputDecoration(labelText: label),
              child: Text(value == null ? l10n.bannersNoLimitLabel : _dateFmt.format(value)),
            ),
          ),
        ),
        if (value != null)
          IconButton(
            tooltip: l10n.bannersClearDateTooltip,
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
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveDialogShell(
      title: widget.existing == null ? l10n.bannersAddTitle : l10n.bannersEditTitle,
      desktopWidth: 460,
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(labelText: l10n.bannersTitleEnLabel),
                validator: _req,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleArCtrl,
                decoration: InputDecoration(labelText: l10n.bannersTitleArLabel),
                validator: _req,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subtitleCtrl,
                decoration: InputDecoration(labelText: l10n.bannersSubtitleEnLabel),
                validator: _req,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subtitleArCtrl,
                decoration: InputDecoration(labelText: l10n.bannersSubtitleArLabel),
                validator: _req,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlCtrl,
                decoration: InputDecoration(labelText: l10n.bannersImageUrlLabel),
                validator: _req,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _linkCtrl,
                decoration: InputDecoration(
                  labelText: l10n.bannersLinkActionLabel,
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.commonActive),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.bannersActiveDateRangeLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _dateField(
                      label: l10n.bannersActiveFromLabel,
                      value: _startDate,
                      isStart: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dateField(
                      label: l10n.bannersActiveUntilLabel,
                      value: _endDate,
                      isStart: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton.icon(
                  onPressed: _openPreview,
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(l10n.bannersPreviewLabel),
                ),
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

/// A simplified, static replica of the mobile app's banner carousel card
/// (see mobile-app/lib/features/home/widgets/banner_carousel.dart) so admins
/// can eyeball roughly how a banner will render before publishing it.
class _BannerPreviewCard extends StatelessWidget {
  const _BannerPreviewCard({required this.banner});
  final PromoBanner banner;

  static const _gradient = [Color(0xFF0EA5A4), Color(0xFF0A6E6D)];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 130,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: _gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
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
                              banner.title.isEmpty
                                  ? l10n.bannersPreviewTitlePlaceholder
                                  : banner.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              banner.subtitle.isEmpty
                                  ? l10n.bannersPreviewSubtitlePlaceholder
                                  : banner.subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.local_offer_rounded,
                        color: Colors.white.withValues(alpha: 0.85),
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          banner.isCurrentlyActive
              ? l10n.bannersPreviewActiveNote
              : l10n.bannersPreviewInactiveNote,
          style: TextStyle(
            fontSize: 12,
            color: banner.isCurrentlyActive
                ? Colors.teal
                : Colors.orange.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
