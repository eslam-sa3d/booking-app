class Instructor {
  final String id;
  final String name;
  final String nameAr;
  final String bio;
  final String bioAr;
  final String? photoUrl;
  final double rating;
  final List<String> specialties;

  const Instructor({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.bio,
    required this.bioAr,
    this.photoUrl,
    this.rating = 4.8,
    this.specialties = const [],
  });

  String localizedName(bool isArabic) => isArabic ? nameAr : name;
  String localizedBio(bool isArabic) => isArabic ? bioAr : bio;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Instructor copyWith({
    String? name,
    String? nameAr,
    String? bio,
    String? bioAr,
    String? photoUrl,
    double? rating,
    List<String>? specialties,
  }) {
    return Instructor(
      id: id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      bio: bio ?? this.bio,
      bioAr: bioAr ?? this.bioAr,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
      specialties: specialties ?? this.specialties,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'bio': bio,
        'bioAr': bioAr,
        'photoUrl': photoUrl,
        'rating': rating,
        'specialties': specialties,
      };

  factory Instructor.fromMap(Map<String, dynamic> map) => Instructor(
        id: map['id'] as String,
        name: map['name'] as String,
        nameAr: map['nameAr'] as String,
        bio: map['bio'] as String? ?? '',
        bioAr: map['bioAr'] as String? ?? '',
        photoUrl: map['photoUrl'] as String?,
        rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
        specialties: ((map['specialties'] as List?) ?? []).map((e) => e as String).toList(),
      );
}
