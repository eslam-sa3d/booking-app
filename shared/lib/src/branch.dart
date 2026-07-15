class Branch {
  final String id;
  final String name;
  final String nameAr;
  final String address;
  final String addressAr;
  final String imageAsset;

  const Branch({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.address,
    required this.addressAr,
    this.imageAsset = 'assets/images/branch_placeholder.png',
  });

  String localizedName(bool isArabic) => isArabic ? nameAr : name;
  String localizedAddress(bool isArabic) => isArabic ? addressAr : address;

  Branch copyWith({String? name, String? nameAr, String? address, String? addressAr, String? imageAsset}) {
    return Branch(
      id: id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      address: address ?? this.address,
      addressAr: addressAr ?? this.addressAr,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'address': address,
        'addressAr': addressAr,
        'imageAsset': imageAsset,
      };

  factory Branch.fromMap(Map<String, dynamic> map) => Branch(
        id: map['id'] as String,
        name: map['name'] as String,
        nameAr: map['nameAr'] as String,
        address: map['address'] as String? ?? '',
        addressAr: map['addressAr'] as String? ?? '',
        imageAsset: map['imageAsset'] as String? ?? 'assets/images/branch_placeholder.png',
      );
}
