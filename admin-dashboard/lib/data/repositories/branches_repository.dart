import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

// Intentionally does NOT mix in AuditedWrite, unlike every other repository
// in this directory: firestore.rules' `branches` rule is a plain
// `allow write: if isStaff();` with no `taggedByCaller()` requirement, so
// there's no `updatedBy` tag for an audit trigger to read, and deletes stay
// a direct Firestore call rather than routing through `adminDelete`. If you
// add audit logging for branches, add the tag here AND a matching rule.
class BranchesRepository {
  BranchesRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('branches');

  Stream<List<Branch>> watchAll() {
    return _col.orderBy('name').snapshots().map(
          (snap) => snap.docs.map((d) => Branch.fromMap({...d.data(), 'id': d.id})).toList(),
        );
  }

  Future<String> create(Branch branch) async {
    final ref = branch.id.isEmpty ? _col.doc() : _col.doc(branch.id);
    await ref.set(branch.toMap()..['id'] = ref.id);
    return ref.id;
  }

  Future<void> update(Branch branch) => _col.doc(branch.id).set(branch.toMap());

  Future<void> delete(String id) => _col.doc(id).delete();
}
