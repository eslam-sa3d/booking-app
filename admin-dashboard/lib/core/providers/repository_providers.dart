import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/app_settings_repository.dart';
import '../../data/repositories/banners_repository.dart';
import '../../data/repositories/bookings_repository.dart';
import '../../data/repositories/branches_repository.dart';
import '../../data/repositories/classes_repository.dart';
import '../../data/repositories/instructors_repository.dart';
import '../../data/repositories/members_repository.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../data/repositories/packages_repository.dart';
import '../../data/repositories/sessions_repository.dart';
import '../../data/repositories/staff_repository.dart';
import '../../data/repositories/transactions_repository.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final functionsProvider = Provider<FirebaseFunctions>((ref) => FirebaseFunctions.instance);

final classesRepositoryProvider = Provider((ref) => ClassesRepository(ref.watch(firestoreProvider)));
final sessionsRepositoryProvider = Provider((ref) => SessionsRepository(ref.watch(firestoreProvider)));
final bannersRepositoryProvider = Provider((ref) => BannersRepository(ref.watch(firestoreProvider)));
final packagesRepositoryProvider = Provider((ref) => PackagesRepository(ref.watch(firestoreProvider)));
final appSettingsRepositoryProvider = Provider((ref) => AppSettingsRepository(ref.watch(firestoreProvider)));
final instructorsRepositoryProvider = Provider((ref) => InstructorsRepository(ref.watch(firestoreProvider)));
final branchesRepositoryProvider = Provider((ref) => BranchesRepository(ref.watch(firestoreProvider)));
final membersRepositoryProvider = Provider((ref) => MembersRepository(ref.watch(firestoreProvider)));
final transactionsRepositoryProvider = Provider((ref) => TransactionsRepository(ref.watch(firestoreProvider)));
final notificationsRepositoryProvider = Provider((ref) => NotificationsRepository(ref.watch(firestoreProvider)));
final bookingsRepositoryProvider = Provider((ref) => BookingsRepository(ref.watch(firestoreProvider)));
final staffRepositoryProvider =
    Provider((ref) => StaffRepository(ref.watch(firestoreProvider), ref.watch(functionsProvider)));
