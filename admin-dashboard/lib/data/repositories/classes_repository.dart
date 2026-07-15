import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

class ClassesRepository {
  ClassesRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('classes');

  Stream<List<SwimClass>> watchClasses() {
    return _col.orderBy('title').snapshots().map(
          (snap) => snap.docs.map((d) => SwimClass.fromMap(d.data())).toList(),
        );
  }

  Future<SwimClass?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return SwimClass.fromMap(doc.data()!);
  }

  Future<String> create(SwimClass swimClass) async {
    final ref = swimClass.id.isEmpty ? _col.doc() : _col.doc(swimClass.id);
    await ref.set(swimClass.copyWith().toMap()..['id'] = ref.id);
    return ref.id;
  }

  Future<void> update(SwimClass swimClass) => _col.doc(swimClass.id).set(swimClass.toMap());

  Future<void> delete(String id) => _col.doc(id).delete();
}
