import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/repository_providers.dart';
import '../../core/widgets/page_scaffold.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  final _colorCtrl = TextEditingController();
  final _logoCtrl = TextEditingController();
  final _termsCtrl = TextEditingController();
  final _privacyCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  List<FaqEntry> _faqEn = [];
  List<FaqEntry> _faqAr = [];
  bool _loaded = false;
  bool _isSaving = false;

  void _hydrate(AppSettings settings) {
    if (_loaded) return;
    _colorCtrl.text = settings.brandPrimaryColorHex;
    _logoCtrl.text = settings.logoUrl ?? '';
    _termsCtrl.text = settings.termsUrl ?? '';
    _privacyCtrl.text = settings.privacyUrl ?? '';
    _whatsappCtrl.text = settings.whatsappNumber ?? '';
    _contactCtrl.text = settings.contactEmail ?? '';
    _faqEn = List.of(settings.faqEn);
    _faqAr = List.of(settings.faqAr);
    _loaded = true;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(appSettingsRepositoryProvider).save(AppSettings(
            brandPrimaryColorHex: _colorCtrl.text.trim(),
            logoUrl: _logoCtrl.text.trim().isEmpty ? null : _logoCtrl.text.trim(),
            faqEn: _faqEn,
            faqAr: _faqAr,
            termsUrl: _termsCtrl.text.trim().isEmpty ? null : _termsCtrl.text.trim(),
            privacyUrl: _privacyCtrl.text.trim().isEmpty ? null : _privacyCtrl.text.trim(),
            whatsappNumber: _whatsappCtrl.text.trim().isEmpty ? null : _whatsappCtrl.text.trim(),
            contactEmail: _contactCtrl.text.trim().isEmpty ? null : _contactCtrl.text.trim(),
          ));
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsSavedMessage)));
      }
    } catch (error) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsSaveFailedMessage(error.toString()))));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addFaq(bool isArabic) {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      final entry = FaqEntry(question: l10n.settingsFaqNewQuestion, answer: l10n.settingsFaqNewAnswer);
      if (isArabic) {
        _faqAr = [..._faqAr, entry];
      } else {
        _faqEn = [..._faqEn, entry];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsStream = ref.watch(appSettingsRepositoryProvider).watch();

    return AdminPageScaffold(
      title: l10n.navSettings,
      actions: [
        FilledButton(onPressed: _isSaving ? null : _save, child: Text(_isSaving ? l10n.commonSaving : l10n.settingsSaveChangesButton)),
      ],
      body: StreamBuilder<AppSettings>(
        stream: settingsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          _hydrate(snapshot.data!);
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.settingsBrandingSection, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 12),
                TextFormField(controller: _colorCtrl, decoration: InputDecoration(labelText: l10n.settingsPrimaryColorLabel)),
                const SizedBox(height: 12),
                TextFormField(controller: _logoCtrl, decoration: InputDecoration(labelText: l10n.settingsLogoUrlLabel)),
                const SizedBox(height: 28),
                Text(l10n.settingsContactSupportSection, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 12),
                TextFormField(controller: _whatsappCtrl, decoration: InputDecoration(labelText: l10n.settingsWhatsappNumberLabel)),
                const SizedBox(height: 12),
                TextFormField(controller: _contactCtrl, decoration: InputDecoration(labelText: l10n.settingsContactEmailLabel)),
                const SizedBox(height: 12),
                TextFormField(controller: _termsCtrl, decoration: InputDecoration(labelText: l10n.settingsTermsUrlLabel)),
                const SizedBox(height: 12),
                TextFormField(controller: _privacyCtrl, decoration: InputDecoration(labelText: l10n.settingsPrivacyUrlLabel)),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(child: Text(l10n.settingsFaqEnglishSection, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                    TextButton.icon(onPressed: () => _addFaq(false), icon: const Icon(Icons.add), label: Text(l10n.commonAdd)),
                  ],
                ),
                for (var i = 0; i < _faqEn.length; i++) _FaqEditor(entry: _faqEn[i], onChanged: (e) => setState(() => _faqEn[i] = e), onDelete: () => setState(() => _faqEn.removeAt(i))),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(child: Text(l10n.settingsFaqArabicSection, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                    TextButton.icon(onPressed: () => _addFaq(true), icon: const Icon(Icons.add), label: Text(l10n.commonAdd)),
                  ],
                ),
                for (var i = 0; i < _faqAr.length; i++) _FaqEditor(entry: _faqAr[i], onChanged: (e) => setState(() => _faqAr[i] = e), onDelete: () => setState(() => _faqAr.removeAt(i))),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FaqEditor extends StatelessWidget {
  const _FaqEditor({required this.entry, required this.onChanged, required this.onDelete});
  final FaqEntry entry;
  final ValueChanged<FaqEntry> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: entry.question,
                    decoration: InputDecoration(labelText: l10n.settingsFaqQuestionLabel),
                    onChanged: (v) => onChanged(FaqEntry(question: v, answer: entry.answer)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: entry.answer,
                    decoration: InputDecoration(labelText: l10n.settingsFaqAnswerLabel),
                    maxLines: 2,
                    onChanged: (v) => onChanged(FaqEntry(question: entry.question, answer: v)),
                  ),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
