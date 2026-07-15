import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class _PromoBanner {
  final String titleEn;
  final String titleAr;
  final String subtitleEn;
  final String subtitleAr;
  final List<Color> colors;
  final IconData icon;
  const _PromoBanner(this.titleEn, this.titleAr, this.subtitleEn, this.subtitleAr, this.colors, this.icon);
}

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key, required this.isArabic});

  final bool isArabic;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  int _page = 0;

  static const _banners = [
    _PromoBanner(
      'Summer offer: 20% off',
      'عرض الصيف: خصم 20%',
      'On Monthly Unlimited packages',
      'على باقات الاشتراك الشهري',
      [AppColors.primary, AppColors.primaryDark],
      Icons.local_offer_rounded,
    ),
    _PromoBanner(
      'New: Ladies-only sessions',
      'جديد: حصص نسائية',
      'Now open at both branches',
      'متاحة الآن في كلا الفرعين',
      [AppColors.accentPink, Color(0xFFB91C5C)],
      Icons.favorite_rounded,
    ),
    _PromoBanner(
      'Private coaching available',
      'التدريب الخاص متاح الآن',
      'Book a 1-on-1 session today',
      'احجز حصة فردية اليوم',
      [AppColors.accentPurple, Color(0xFF5B21B6)],
      Icons.star_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 130,
          child: PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: banner.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.isArabic ? banner.titleAr : banner.titleEn,
                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.isArabic ? banner.subtitleAr : banner.subtitleEn,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Icon(banner.icon, color: Colors.white.withValues(alpha: 0.85), size: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _page ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _page ? AppColors.primary : AppColors.primary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
