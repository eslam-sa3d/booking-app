import 'firestore_codec.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final String preferredLanguage; // 'en' or 'ar'
  final String role; // 'customer' | 'staff' | 'admin' — mirror of the Auth custom claim, not authoritative
  final bool suspended;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.preferredLanguage = 'en',
    this.role = 'customer',
    this.suspended = false,
    required this.createdAt,
  });

  bool get isStaffOrAdmin => role == 'staff' || role == 'admin';
  bool get isAdmin => role == 'admin';

  AppUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? preferredLanguage,
    String? role,
    bool? suspended,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      role: role ?? this.role,
      suspended: suspended ?? this.suspended,
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
        'role': role,
        'suspended': suspended,
        'createdAt': createdAt,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
        phone: map['phone'] as String,
        photoUrl: map['photoUrl'] as String?,
        preferredLanguage: map['preferredLanguage'] as String? ?? 'en',
        role: map['role'] as String? ?? 'customer',
        suspended: map['suspended'] as bool? ?? false,
        createdAt: parseTimestamp(map['createdAt']),
      );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}
