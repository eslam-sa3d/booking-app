class SwimClass {
  final String id;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  // References categories/{id} docs (see Category) — plain strings rather
  // than a closed enum, so admin can add/rename/remove categories at
  // runtime without a mobile/admin app release.
  final List<String> categories;
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
    this.currency = 'EGP',
    required this.instructorId,
    required this.branchId,
    this.rating = 4.7,
    this.reviewCount = 0,
    this.heroColorHex = '#0EA5A4',
    this.heroIcon = 'pool',
  });

  String localizedTitle(bool isArabic) => isArabic ? titleAr : title;
  String localizedDescription(bool isArabic) => isArabic ? descriptionAr : description;

  SwimClass copyWith({
    String? title,
    String? titleAr,
    String? description,
    String? descriptionAr,
    List<String>? categories,
    int? durationMinutes,
    double? price,
    String? currency,
    String? instructorId,
    String? branchId,
    double? rating,
    int? reviewCount,
    String? heroColorHex,
    String? heroIcon,
  }) {
    return SwimClass(
      id: id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      categories: categories ?? this.categories,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      instructorId: instructorId ?? this.instructorId,
      branchId: branchId ?? this.branchId,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      heroColorHex: heroColorHex ?? this.heroColorHex,
      heroIcon: heroIcon ?? this.heroIcon,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'titleAr': titleAr,
        'description': description,
        'descriptionAr': descriptionAr,
        'categories': categories,
        'durationMinutes': durationMinutes,
        'price': price,
        'currency': currency,
        'instructorId': instructorId,
        'branchId': branchId,
        'rating': rating,
        'reviewCount': reviewCount,
        'heroColorHex': heroColorHex,
        'heroIcon': heroIcon,
      };

  factory SwimClass.fromMap(Map<String, dynamic> map) => SwimClass(
        id: map['id'] as String,
        title: map['title'] as String,
        titleAr: map['titleAr'] as String,
        description: map['description'] as String? ?? '',
        descriptionAr: map['descriptionAr'] as String? ?? '',
        categories: ((map['categories'] as List?) ?? []).cast<String>(),
        durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 45,
        price: (map['price'] as num?)?.toDouble() ?? 0,
        currency: map['currency'] as String? ?? 'EGP',
        instructorId: map['instructorId'] as String? ?? '',
        branchId: map['branchId'] as String? ?? '',
        rating: (map['rating'] as num?)?.toDouble() ?? 4.7,
        reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
        heroColorHex: map['heroColorHex'] as String? ?? '#0EA5A4',
        heroIcon: map['heroIcon'] as String? ?? 'pool',
      );
}
