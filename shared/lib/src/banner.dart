import 'firestore_codec.dart';

class PromoBanner {
  final String id;
  final String title;
  final String titleAr;
  final String subtitle;
  final String subtitleAr;
  final String imageUrl;
  final String? linkAction; // e.g. "class:{id}" or "packages"
  final int order;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  const PromoBanner({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.subtitle,
    required this.subtitleAr,
    required this.imageUrl,
    this.linkAction,
    this.order = 0,
    this.isActive = true,
    this.startDate,
    this.endDate,
  });

  String localizedTitle(bool isArabic) => isArabic ? titleAr : title;
  String localizedSubtitle(bool isArabic) => isArabic ? subtitleAr : subtitle;

  bool get isCurrentlyActive {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  PromoBanner copyWith({
    String? title,
    String? titleAr,
    String? subtitle,
    String? subtitleAr,
    String? imageUrl,
    String? linkAction,
    int? order,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return PromoBanner(
      id: id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      subtitle: subtitle ?? this.subtitle,
      subtitleAr: subtitleAr ?? this.subtitleAr,
      imageUrl: imageUrl ?? this.imageUrl,
      linkAction: linkAction ?? this.linkAction,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'titleAr': titleAr,
        'subtitle': subtitle,
        'subtitleAr': subtitleAr,
        'imageUrl': imageUrl,
        'linkAction': linkAction,
        'order': order,
        'isActive': isActive,
        'startDate': startDate,
        'endDate': endDate,
      };

  factory PromoBanner.fromMap(Map<String, dynamic> map) => PromoBanner(
        id: map['id'] as String,
        title: map['title'] as String,
        titleAr: map['titleAr'] as String? ?? '',
        subtitle: map['subtitle'] as String? ?? '',
        subtitleAr: map['subtitleAr'] as String? ?? '',
        imageUrl: map['imageUrl'] as String? ?? '',
        linkAction: map['linkAction'] as String?,
        order: (map['order'] as num?)?.toInt() ?? 0,
        isActive: map['isActive'] as bool? ?? true,
        startDate: parseTimestampOrNull(map['startDate']),
        endDate: parseTimestampOrNull(map['endDate']),
      );
}
