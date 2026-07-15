import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/widgets/glass_app_bar.dart';

class SupportFaqScreen extends ConsumerWidget {
  const SupportFaqScreen({super.key});

  static const _faqsEn = [
    ('How do I book a class?', 'Browse classes on the Home tab or the Calendar tab, pick an available time slot, choose who it\'s for, and confirm.'),
    ('Can I cancel a booking?', 'Yes — cancellations are free up to 24 hours before the session. Go to My Bookings to cancel.'),
    ('What happens if a class is full?', 'You can join the waitlist. We\'ll notify you the moment a spot opens up.'),
    ('How do packages work?', 'Purchase a package once, then use its sessions to book any class until it expires.'),
    ('Can I book for my children?', 'Yes — add them as family members in your Profile, then select them when booking.'),
  ];

  static const _faqsAr = [
    ('كيف أحجز حصة؟', 'تصفح الحصص من الرئيسية أو التقويم، اختر موعداً متاحاً، حدد لمن الحجز، ثم أكّد.'),
    ('هل يمكنني إلغاء الحجز؟', 'نعم — الإلغاء مجاني حتى 24 ساعة قبل الحصة. اذهب إلى حجوزاتي للإلغاء.'),
    ('ماذا لو كانت الحصة ممتلئة؟', 'يمكنك الانضمام لقائمة الانتظار، وسنعلمك فور توفر مكان.'),
    ('كيف تعمل الباقات؟', 'اشترِ الباقة مرة واحدة، ثم استخدم حصصها لحجز أي حصة حتى تنتهي صلاحيتها.'),
    ('هل يمكنني الحجز لأطفالي؟', 'نعم — أضفهم كأفراد عائلة في ملفك الشخصي، ثم اخترهم عند الحجز.'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.watch(isArabicProvider);
    final faqs = isArabic ? _faqsAr : _faqsEn;

    return Scaffold(
      appBar: GlassAppBar(title: Text(l10n.faqTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final (question, answer) = faqs[index];
          return Card(
            child: ExpansionTile(
              title: Text(question, style: const TextStyle(fontWeight: FontWeight.w700)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(answer)],
            ),
          );
        },
      ),
    );
  }
}
