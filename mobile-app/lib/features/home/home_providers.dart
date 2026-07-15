import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cache/local_cache.dart';
import '../../core/providers/repository_providers.dart';
import '../../data/models/models.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedBranchProvider = StateProvider<String?>((ref) => null);

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(classRepositoryProvider).getCategories();
});

final categoriesMapProvider = FutureProvider<Map<String, Category>>((ref) async {
  final categories = await ref.watch(categoriesProvider.future);
  return {for (final c in categories) c.id: c};
});

final branchesProvider = FutureProvider<List<Branch>>((ref) {
  return ref.watch(classRepositoryProvider).getBranches();
});

final instructorsMapProvider = FutureProvider<Map<String, Instructor>>((ref) async {
  final instructors = await ref.watch(classRepositoryProvider).getInstructors();
  return {for (final i in instructors) i.id: i};
});

/// Live banner carousel — a [StreamProvider] backed by
/// [BannerRepository.watchActiveBanners] so newly published/edited banners
/// show up without the user having to pull-to-refresh.
final bannersProvider = StreamProvider<List<PromoBanner>>((ref) {
  return ref.watch(bannerRepositoryProvider).watchActiveBanners();
});

const _classesPageSize = 20;
const _classesCacheKey = 'classes';

/// Home's class list: the current (category/search/branch-filtered) first
/// page plus "load more" pagination, with an offline fallback to the last
/// successfully-fetched list (see [LocalCache]) when a fresh fetch fails.
class ClassesListState {
  const ClassesListState({required this.items, this.nextCursor, this.isLoadingMore = false, this.isOffline = false});

  final List<SwimClass> items;
  final String? nextCursor;
  final bool isLoadingMore;

  /// True when [items] came from [LocalCache] because the live fetch failed
  /// (no network, backend error, etc.) rather than from a fresh query.
  final bool isOffline;

  bool get hasMore => nextCursor != null;

  ClassesListState copyWith({List<SwimClass>? items, String? nextCursor, bool? isLoadingMore, bool? isOffline}) {
    return ClassesListState(
      items: items ?? this.items,
      nextCursor: nextCursor,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

class ClassesNotifier extends AsyncNotifier<ClassesListState> {
  List<String>? get _categories {
    final category = ref.watch(selectedCategoryProvider);
    return category != null ? [category] : null;
  }

  @override
  Future<ClassesListState> build() async {
    final categories = _categories;
    final query = ref.watch(searchQueryProvider);
    final branchId = ref.watch(selectedBranchProvider);
    final repo = ref.watch(classRepositoryProvider);

    try {
      final page = await repo.getClassesPage(
        categories: categories,
        branchId: branchId,
        query: query,
        limit: _classesPageSize,
      );
      unawaited(LocalCache.putList(_classesCacheKey, page.items.map((c) => c.toMap()).toList()));
      return ClassesListState(items: page.items, nextCursor: page.nextCursor);
    } catch (error) {
      final cached = LocalCache.getList(_classesCacheKey);
      if (cached != null) {
        return ClassesListState(items: cached.map(SwimClass.fromMap).toList(), isOffline: true);
      }
      rethrow;
    }
  }

  /// Fetches the next page and appends it to the current list. No-ops if
  /// there's nothing more, a page is already loading, or the current state
  /// isn't loaded yet.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final repo = ref.read(classRepositoryProvider);
      final page = await repo.getClassesPage(
        categories: _categories,
        branchId: ref.read(selectedBranchProvider),
        query: ref.read(searchQueryProvider),
        limit: _classesPageSize,
        startAfterId: current.nextCursor,
      );
      final merged = [...current.items, ...page.items];
      state = AsyncData(ClassesListState(items: merged, nextCursor: page.nextCursor));
      unawaited(LocalCache.putList(_classesCacheKey, merged.map((c) => c.toMap()).toList()));
    } catch (_) {
      // Best-effort — leave the already-loaded items in place, just stop
      // showing the loading-more spinner.
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

final classesProvider = AsyncNotifierProvider<ClassesNotifier, ClassesListState>(ClassesNotifier.new);
