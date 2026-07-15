import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../data/models/models.dart';
import '../auth/auth_controller.dart';

final availablePackagesProvider = FutureProvider<List<SwimPackage>>((ref) {
  return ref.watch(packageRepositoryProvider).getPackages();
});

final userPackagesProvider = FutureProvider<List<UserPackage>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(packageRepositoryProvider).getUserPackages(user.id);
});
