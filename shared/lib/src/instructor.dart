class Instructor {
  final String id;
  final String name;
  final String nameAr;
  final String bio;
  final String bioAr;
  final double rating;
  final List<String> specialties;

  const Instructor({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.bio,
    required this.bioAr,
    this.rating = 4.8,
    this.specialties = const [],
  });

  String localizedName(bool isArabic) => isArabic ? nameAr : name;
  String localizedBio(bool isArabic) => isArabic ? bioAr : bio;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
