import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/widgets/glass_app_bar.dart';
import 'app_settings_provider.dart';

class SupportFaqScreen extends ConsumerWidget {
  const SupportFaqScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.watch(isArabicProvider);
    final settingsAsync = ref.watch(appSettingsFutureProvider);

    return Scaffold(
      appBar: GlassAppBar(title: Text(l10n.faqTitle)),
      body: settingsAsync.when(
        data: (settings) {
          final faqs = isArabic ? settings.faqAr : settings.faqEn;
          if (faqs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  isArabic ? 'لا توجد أسئلة شائعة متاحة حالياً.' : 'No FAQs are available yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: faqs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = faqs[index];
              return Card(
                child: ExpansionTile(
                  title: Text(entry.question, style: const TextStyle(fontWeight: FontWeight.w700)),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(entry.answer)],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              isArabic ? 'تعذر تحميل الأسئلة الشائعة. حاول مرة أخرى لاحقاً.' : 'Couldn\'t load the FAQs. Please try again later.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
