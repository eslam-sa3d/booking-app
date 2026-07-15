import 'enums.dart';

class SwimClass {
  final String id;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final List<ClassCategory> categories;
  final int durationMinutes;
  final double price;
  final String currency;
  final String instructorId;
  final String branchId;
  final double rating;
  final int reviewCount;
  final String heroColorHex;
  final String heroIcon; // Material icon name used by placeholder art

  const SwimClass({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.categories,
    required this.durationMinutes,
    required this.price,
    this.currency = 'SAR',
    required this.instructorId,
    required this.branchId,
    this.rating = 4.7,
    this.reviewCount = 0,
    this.heroColorHex = '#0EA5A4',
    this.heroIcon = 'pool',
  });

  String localizedTitle(bool isArabic) => isArabic ? titleAr : title;
  String localizedDescription(bool isArabic) => isArabic ? descriptionAr : description;
}
