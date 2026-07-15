import '../models/models.dart';

abstract class FamilyRepository {
  Future<List<FamilyMember>> getFamilyMembers(String userId);

  Future<FamilyMember> addFamilyMember(FamilyMember member);

  Future<FamilyMember> updateFamilyMember(FamilyMember member);

  Future<void> deleteFamilyMember(String id);
}
