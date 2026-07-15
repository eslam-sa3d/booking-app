import '../../models/models.dart';
import '../../repositories/banner_repository.dart';

class MockBannerRepository implements BannerRepository {
  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 300));

  static final _banners = [
    const PromoBanner(
      id: 'bn1',
      title: 'Summer offer: 20% off',
      titleAr: 'عرض الصيف: خصم 20%',
      subtitle: 'On Monthly Unlimited packages',
      subtitleAr: 'على باقات الاشتراك الشهري',
      imageUrl: '',
      linkAction: 'packages',
      order: 0,
    ),
    const PromoBanner(
      id: 'bn2',
      title: 'New: Ladies-only sessions',
      titleAr: 'جديد: حصص نسائية',
      subtitle: 'Now open at both branches',
      subtitleAr: 'متاحة الآن في كلا الفرعين',
      imageUrl: '',
      order: 1,
    ),
    const PromoBanner(
      id: 'bn3',
      title: 'Private coaching available',
      titleAr: 'التدريب الخاص متاح الآن',
      subtitle: 'Book a 1-on-1 session today',
      subtitleAr: 'احجز حصة فردية اليوم',
      imageUrl: '',
      order: 2,
    ),
  ];

  @override
  Future<List<PromoBanner>> getActiveBanners() async {
    await _delay();
    return _banners.where((b) => b.isCurrentlyActive).toList()..sort((a, b) => a.order.compareTo(b.order));
  }
}
