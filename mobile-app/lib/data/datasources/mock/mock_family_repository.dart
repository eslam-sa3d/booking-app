import '../../models/models.dart';
import '../../repositories/family_repository.dart';
import 'mock_database.dart';

class MockFamilyRepository implements FamilyRepository {
  final _db = MockDatabase.instance;

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<FamilyMember>> getFamilyMembers(String userId) async {
    await _delay();
    return _db.familyMembers.where((f) => f.userId == userId).toList();
  }

  @override
  Future<FamilyMember> addFamilyMember(FamilyMember member) async {
    await _delay();
    final created = FamilyMember(
      id: _db.nextId('f'),
      userId: member.userId,
      name: member.name,
      dateOfBirth: member.dateOfBirth,
      gender: member.gender,
      medicalNotes: member.medicalNotes,
      swimmingLevel: member.swimmingLevel,
      photoUrl: member.photoUrl,
    );
    _db.familyMembers.add(created);
    return created;
  }

  @override
  Future<FamilyMember> updateFamilyMember(FamilyMember member) async {
    await _delay();
    final index = _db.familyMembers.indexWhere((f) => f.id == member.id);
    if (index == -1) throw Exception('Family member not found');
    _db.familyMembers[index] = member;
    return member;
  }

  @override
  Future<void> deleteFamilyMember(String id) async {
    await _delay();
    _db.familyMembers.removeWhere((f) => f.id == id);
  }
}
