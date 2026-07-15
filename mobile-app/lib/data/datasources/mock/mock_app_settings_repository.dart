import '../../models/models.dart';
import '../../repositories/app_settings_repository.dart';

/// In-memory stand-in for [FirebaseAppSettingsRepository], matching the
/// pattern of the other Mock* repositories in this directory. Not yet wired
/// into test/test_overrides.dart's testRepositoryOverrides list — add
/// `appSettingsRepositoryProvider.overrideWithValue(MockAppSettingsRepository())`
/// there if a widget test starts exercising the FAQ/settings screens.
class MockAppSettingsRepository implements AppSettingsRepository {
  const MockAppSettingsRepository();

  @override
  Future<AppSettings> getSettings() async {
    return const AppSettings(
      faqEn: [
        FaqEntry(
          question: 'How do I book a class?',
          answer: 'Browse classes on the Home tab or the Calendar tab, pick an available time slot, choose who it\'s for, and confirm.',
        ),
        FaqEntry(
          question: 'Can I cancel a booking?',
          answer: 'Yes — cancellations are free up to 24 hours before the session. Go to My Bookings to cancel.',
        ),
      ],
      faqAr: [
        FaqEntry(question: 'كيف أحجز حصة؟', answer: 'تصفح الحصص من الرئيسية أو التقويم، اختر موعداً متاحاً، حدد لمن الحجز، ثم أكّد.'),
        FaqEntry(question: 'هل يمكنني إلغاء الحجز؟', answer: 'نعم — الإلغاء مجاني حتى 24 ساعة قبل الحصة. اذهب إلى حجوزاتي للإلغاء.'),
      ],
      whatsappNumber: '966500000000',
      contactEmail: 'support@example.com',
    );
  }
}
