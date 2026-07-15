import '../models/models.dart';

abstract class ClassRepository {
  Future<List<SwimClass>> getClasses({
    List<ClassCategory>? categories,
    String? branchId,
    String? query,
  });

  Future<SwimClass> getClassById(String id);

  Future<List<SwimSession>> getSessionsForClass(String classId);

  Future<List<SwimSession>> getSessionsForDate(DateTime date);

  Future<List<SwimSession>> getSessionsInRange(DateTime start, DateTime end);

  Future<SwimSession?> getSessionById(String sessionId);

  Future<Instructor> getInstructor(String id);

  Future<List<Instructor>> getInstructors();

  Future<Branch> getBranch(String id);

  Future<List<Branch>> getBranches();
}
