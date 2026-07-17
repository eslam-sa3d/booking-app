class PaymentMethodConfig {
  final String id;
  final String nameEn;
  final String nameAr;
  final int order;
  final bool isActive;

  const PaymentMethodConfig({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.order = 0,
    this.isActive = true,
  });

  String localizedName(bool isArabic) => isArabic ? nameAr : nameEn;

  PaymentMethodConfig copyWith({String? nameEn, String? nameAr, int? order, bool? isActive}) => PaymentMethodConfig(
        id: id,
        nameEn: nameEn ?? this.nameEn,
        nameAr: nameAr ?? this.nameAr,
        order: order ?? this.order,
        isActive: isActive ?? this.isActive,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'order': order,
        'isActive': isActive,
      };

  factory PaymentMethodConfig.fromMap(Map<String, dynamic> map) => PaymentMethodConfig(
        id: map['id'] as String,
        nameEn: map['nameEn'] as String,
        nameAr: map['nameAr'] as String? ?? '',
        order: (map['order'] as num?)?.toInt() ?? 0,
        isActive: map['isActive'] as bool? ?? true,
      );
}
