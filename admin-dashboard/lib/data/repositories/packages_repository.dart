import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

class PackagesRepository {
  PackagesRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('packages');

  Stream<List<SwimPackage>> watchAll() {
    return _col.snapshots().map((snap) => snap.docs.map((d) => SwimPackage.fromMap(d.data())).toList());
  }

  Future<String> create(SwimPackage package) async {
    final ref = package.id.isEmpty ? _col.doc() : _col.doc(package.id);
    await ref.set(package.toMap()..['id'] = ref.id);
    return ref.id;
  }

  Future<void> update(SwimPackage package) => _col.doc(package.id).set(package.toMap());

  Future<void> delete(String id) => _col.doc(id).delete();
}
