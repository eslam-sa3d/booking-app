import '../../models/models.dart';
import '../../repositories/class_repository.dart';
import 'mock_database.dart';
import 'mock_seed_data.dart';

class MockClassRepository implements ClassRepository {
  final _db = MockDatabase.instance;

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<SwimClass>> getClasses({
    List<ClassCategory>? categories,
    String? branchId,
    String? query,
  }) async {
    await _delay();
    return MockSeedData.classes.where((c) {
      if (branchId != null && c.branchId != branchId) return false;
      if (categories != null &&
          categories.isNotEmpty &&
          !c.categories.any((cat) => categories.contains(cat))) {
        return false;
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        if (!c.title.toLowerCase().contains(q) && !c.titleAr.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Future<SwimClass> getClassById(String id) async {
    await _delay();
    return MockSeedData.classes.firstWhere((c) => c.id == id);
  }

  @override
  Future<List<SwimSession>> getSessionsForClass(String classId) async {
    await _delay();
    return _db.sessions.where((s) => s.classId == classId && !s.isPast).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  @override
  Future<List<SwimSession>> getSessionsForDate(DateTime date) async {
    await _delay();
    return _db.sessions
        .where((s) => s.date.year == date.year && s.date.month == date.month && s.date.day == date.day)
        .toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  }

  @override
  Future<List<SwimSession>> getSessionsInRange(DateTime start, DateTime end) async {
    await _delay();
    return _db.sessions
        .where((s) => !s.date.isBefore(start) && !s.date.isAfter(end))
        .toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  @override
  Future<SwimSession?> getSessionById(String sessionId) async {
    await _delay();
    try {
      return _db.sessions.firstWhere((s) => s.id == sessionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Instructor> getInstructor(String id) async {
    await _delay();
    return MockSeedData.instructors.firstWhere((i) => i.id == id);
  }

  @override
  Future<List<Instructor>> getInstructors() async {
    await _delay();
    return MockSeedData.instructors;
  }

  @override
  Future<Branch> getBranch(String id) async {
    await _delay();
    return MockSeedData.branches.firstWhere((b) => b.id == id);
  }

  @override
  Future<List<Branch>> getBranches() async {
    await _delay();
    return MockSeedData.branches;
  }
}
