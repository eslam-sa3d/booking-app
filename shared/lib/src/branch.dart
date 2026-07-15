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
}
