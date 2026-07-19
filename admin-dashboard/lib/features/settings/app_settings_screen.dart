import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $error')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addFaq(bool isArabic) {
    setState(() {
      final entry = const FaqEntry(question: 'New question', answer: 'New answer');
      if (isArabic) {
        _faqAr = [..._faqAr, entry];
      } else {
        _faqEn = [..._faqEn, entry];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsStream = ref.watch(appSettingsRepositoryProvider).watch();

    return AdminPageScaffold(
      title: 'App Content & Settings',
      actions: [
        FilledButton(onPressed: _isSaving ? null : _save, child: Text(_isSaving ? 'Saving…' : 'Save changes')),
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
                const Text('Branding', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 12),
                TextFormField(controller: _colorCtrl, decoration: const InputDecoration(labelText: 'Primary color (hex)')),
                const SizedBox(height: 12),
                TextFormField(controller: _logoCtrl, decoration: const InputDecoration(labelText: 'Logo URL')),
                const SizedBox(height: 28),
                const Text('Contact & Support', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 12),
                TextFormField(controller: _whatsappCtrl, decoration: const InputDecoration(labelText: 'WhatsApp number (e.g. +966500000000)')),
                const SizedBox(height: 12),
                TextFormField(controller: _contactCtrl, decoration: const InputDecoration(labelText: 'Contact email')),
                const SizedBox(height: 12),
                TextFormField(controller: _termsCtrl, decoration: const InputDecoration(labelText: 'Terms & conditions URL')),
                const SizedBox(height: 12),
                TextFormField(controller: _privacyCtrl, decoration: const InputDecoration(labelText: 'Privacy policy URL')),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(child: Text('FAQ (English)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                    TextButton.icon(onPressed: () => _addFaq(false), icon: const Icon(Icons.add), label: const Text('Add')),
                  ],
                ),
                for (var i = 0; i < _faqEn.length; i++) _FaqEditor(entry: _faqEn[i], onChanged: (e) => setState(() => _faqEn[i] = e), onDelete: () => setState(() => _faqEn.removeAt(i))),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(child: Text('FAQ (Arabic)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                    TextButton.icon(onPressed: () => _addFaq(true), icon: const Icon(Icons.add), label: const Text('Add')),
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
                    decoration: const InputDecoration(labelText: 'Question'),
                    onChanged: (v) => onChanged(FaqEntry(question: v, answer: entry.answer)),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: entry.answer,
                    decoration: const InputDecoration(labelText: 'Answer'),
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
