import 'enums.dart';
import 'firestore_codec.dart';

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

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'titleAr': titleAr,
        'iconName': iconName,
        'earnedAt': earnedAt,
      };

  factory SwimBadge.fromMap(Map<String, dynamic> map) => SwimBadge(
        id: map['id'] as String,
        title: map['title'] as String,
        titleAr: map['titleAr'] as String,
        iconName: map['iconName'] as String? ?? 'emoji_events',
        earnedAt: parseTimestamp(map['earnedAt']),
      );
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'note': note,
        'noteAr': noteAr,
        'instructorName': instructorName,
        'date': date,
      };

  factory ProgressNote.fromMap(Map<String, dynamic> map) => ProgressNote(
        id: map['id'] as String,
        note: map['note'] as String,
        noteAr: map['noteAr'] as String? ?? '',
        instructorName: map['instructorName'] as String? ?? '',
        date: parseTimestamp(map['date']),
      );
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
    List<SwimBadge>? badges,
    List<ProgressNote>? progressNotes,
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
      badges: badges ?? this.badges,
      progressNotes: progressNotes ?? this.progressNotes,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'dateOfBirth': dateOfBirth,
        'gender': gender.name,
        'medicalNotes': medicalNotes,
        'swimmingLevel': swimmingLevel,
        'photoUrl': photoUrl,
        'badges': badges.map((b) => b.toMap()).toList(),
        'progressNotes': progressNotes.map((n) => n.toMap()).toList(),
      };

  factory FamilyMember.fromMap(Map<String, dynamic> map) => FamilyMember(
        id: map['id'] as String,
        userId: map['userId'] as String,
        name: map['name'] as String,
        dateOfBirth: parseTimestamp(map['dateOfBirth']),
        gender: Gender.fromName(map['gender'] as String? ?? 'male'),
        medicalNotes: map['medicalNotes'] as String? ?? '',
        swimmingLevel: (map['swimmingLevel'] as num?)?.toInt() ?? 1,
        photoUrl: map['photoUrl'] as String?,
        badges: ((map['badges'] as List?) ?? [])
            .map((b) => SwimBadge.fromMap(Map<String, dynamic>.from(b as Map)))
            .toList(),
        progressNotes: ((map['progressNotes'] as List?) ?? [])
            .map((n) => ProgressNote.fromMap(Map<String, dynamic>.from(n as Map)))
            .toList(),
      );
}
