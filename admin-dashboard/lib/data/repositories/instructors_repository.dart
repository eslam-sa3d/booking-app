import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared/shared.dart';

class InstructorsRepository {
  InstructorsRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('instructors');

  Stream<List<Instructor>> watchAll() {
    return _col.orderBy('name').snapshots().map(
          (snap) => snap.docs.map((d) => Instructor.fromMap(d.data())).toList(),
        );
  }

  Future<String> create(Instructor instructor) async {
    final ref = instructor.id.isEmpty ? _col.doc() : _col.doc(instructor.id);
    await ref.set(instructor.toMap()..['id'] = ref.id);
    return ref.id;
  }

  Future<void> update(Instructor instructor) => _col.doc(instructor.id).set(instructor.toMap());

  Future<void> delete(String id) => _col.doc(id).delete();
}
