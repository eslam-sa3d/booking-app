class Category {
  final String id;
  final String nameEn;
  final String nameAr;
  final int order;

  const Category({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.order = 0,
  });

  String localizedName(bool isArabic) => isArabic ? nameAr : nameEn;

  Category copyWith({String? nameEn, String? nameAr, int? order}) => Category(
        id: id,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
        order: order ?? this.order,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'order': order,
      };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'] as String,
        nameEn: map['nameEn'] as String,
        nameAr: map['nameAr'] as String,
        order: (map['order'] as num?)?.toInt() ?? 0,
      );
}
