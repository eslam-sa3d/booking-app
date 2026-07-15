import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/repository_providers.dart';
import '../../data/models/models.dart';
import '../auth/auth_controller.dart';

final familyMembersProvider = FutureProvider<List<FamilyMember>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(familyRepositoryProvider).getFamilyMembers(user.id);
});
