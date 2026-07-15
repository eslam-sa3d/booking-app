class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String preferredLanguage; // 'en' or 'ar'
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.preferredLanguage = 'en',
    required this.createdAt,
  });

  AppUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? preferredLanguage,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'photoUrl': photoUrl,
        'preferredLanguage': preferredLanguage,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
        phone: map['phone'] as String,
        photoUrl: map['photoUrl'] as String?,
        preferredLanguage: map['preferredLanguage'] as String? ?? 'en',
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
