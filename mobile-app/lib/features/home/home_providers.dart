import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../data/models/models.dart';

final selectedCategoryProvider = StateProvider<ClassCategory?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

final classesProvider = FutureProvider<List<SwimClass>>((ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider);
  return ref.watch(classRepositoryProvider).getClasses(
        categories: category != null ? [category] : null,
        query: query,
      );
});

final instructorsMapProvider = FutureProvider<Map<String, Instructor>>((ref) async {
  final instructors = await ref.watch(classRepositoryProvider).getInstructors();
  return {for (final i in instructors) i.id: i};
});

final bannersProvider = FutureProvider<List<PromoBanner>>((ref) {
  return ref.watch(bannerRepositoryProvider).getActiveBanners();
});
