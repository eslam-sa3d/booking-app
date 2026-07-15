import '../models/models.dart';

/// A single page of [SwimClass] results from [ClassRepository.getClassesPage].
///
/// [nextCursor] is the id to pass back as `startAfterId` to fetch the
/// following page, or `null` when this was the last page.
class ClassesPage {
  const ClassesPage({required this.items, this.nextCursor});

  final List<SwimClass> items;
  final String? nextCursor;

  bool get hasMore => nextCursor != null;
}

abstract class ClassRepository {
  Future<List<SwimClass>> getClasses({
    List<String>? categories,
    String? branchId,
    String? query,
  });

  /// Paginated variant of [getClasses] for list UIs that want a "load more"
  /// affordance instead of fetching the whole collection at once. Applies
  /// the same category/branch/query filtering as [getClasses]. Pass the
  /// previous page's [ClassesPage.nextCursor] as [startAfterId] to fetch the
  /// following page.
  Future<ClassesPage> getClassesPage({
    List<String>? categories,
    String? branchId,
    String? query,
    int limit = 20,
    String? startAfterId,
  });

  /// The admin-managed category taxonomy (see Category) — replaces the old
  /// fixed ClassCategory enum so staff can add/rename/remove categories
  /// without a code change.
  Future<List<Category>> getCategories();

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
