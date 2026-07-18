import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/models.dart';
import '../../repositories/family_repository.dart';

class FirebaseFamilyRepository implements FamilyRepository {
  FirebaseFamilyRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _db.collection('users').doc(userId).collection('familyMembers');

  @override
  Future<List<FamilyMember>> getFamilyMembers(String userId) async {
    final snap = await _col(userId).get();
    return snap.docs.map((d) => FamilyMember.fromMap({...d.data(), 'id': d.id})).toList();
  }

  @override
  Future<FamilyMember> addFamilyMember(FamilyMember member) async {
    final ref = _col(member.userId).doc();
    final created = member.copyWith();
    final map = created.toMap()..['id'] = ref.id;
    await ref.set(map);
    return FamilyMember.fromMap(map);
  }

  @override
  Future<FamilyMember> updateFamilyMember(FamilyMember member) async {
    await _col(member.userId).doc(member.id).set(member.toMap());
    return member;
  }

  @override
  Future<void> deleteFamilyMember(String userId, String id) => _col(userId).doc(id).delete();
}
