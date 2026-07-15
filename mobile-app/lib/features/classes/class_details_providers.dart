import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../data/models/models.dart';

final classByIdProvider = FutureProvider.family<SwimClass, String>((ref, id) {
  return ref.watch(classRepositoryProvider).getClassById(id);
});

final instructorByIdProvider = FutureProvider.family<Instructor, String>((ref, id) {
  return ref.watch(classRepositoryProvider).getInstructor(id);
});

final branchByIdProvider = FutureProvider.family<Branch, String>((ref, id) {
  return ref.watch(classRepositoryProvider).getBranch(id);
});

final sessionsForClassProvider = FutureProvider.family<List<SwimSession>, String>((ref, classId) {
  return ref.watch(classRepositoryProvider).getSessionsForClass(classId);
});

final reviewsForClassProvider = FutureProvider.family<List<Review>, String>((ref, classId) {
  return ref.watch(reviewRepositoryProvider).getReviewsForClass(classId);
});
