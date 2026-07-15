import 'enums.dart';

class SwimBadge {
  final String id;
  final String title;
  final String titleAr;
  final String iconName; // maps to a Material icon in the UI layer
  final DateTime earnedAt;

  const SwimBadge({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.iconName,
    required this.earnedAt,
  });

  String localizedTitle(bool isArabic) => isArabic ? titleAr : title;
}

class ProgressNote {
  final String id;
  final String note;
  final String noteAr;
  final String instructorName;
  final DateTime date;

  const ProgressNote({
    required this.id,
    required this.note,
    required this.noteAr,
    required this.instructorName,
    required this.date,
  });

  String localizedNote(bool isArabic) => isArabic ? noteAr : note;
}

class FamilyMember {
  final String id;
  final String userId;
  final String name;
  final DateTime dateOfBirth;
  final Gender gender;
  final String medicalNotes;
  final int swimmingLevel; // 1-5
  final String? photoUrl;
  final List<SwimBadge> badges;
  final List<ProgressNote> progressNotes;

  const FamilyMember({
    required this.id,
    required this.userId,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    this.medicalNotes = '',
    this.swimmingLevel = 1,
    this.photoUrl,
    this.badges = const [],
    this.progressNotes = const [],
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  FamilyMember copyWith({
    String? name,
    DateTime? dateOfBirth,
    Gender? gender,
    String? medicalNotes,
    int? swimmingLevel,
    String? photoUrl,
  }) {
    return FamilyMember(
      id: id,
      userId: userId,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      swimmingLevel: swimmingLevel ?? this.swimmingLevel,
      photoUrl: photoUrl ?? this.photoUrl,
      badges: badges,
      progressNotes: progressNotes,
    );
  }
}
