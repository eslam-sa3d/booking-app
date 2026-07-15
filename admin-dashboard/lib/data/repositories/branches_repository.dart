import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

class BranchesRepository {
  BranchesRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('branches');

  Stream<List<Branch>> watchAll() {
    return _col.orderBy('name').snapshots().map(
          (snap) => snap.docs.map((d) => Branch.fromMap(d.data())).toList(),
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
