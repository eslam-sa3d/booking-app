import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/app_settings_repository.dart';
import '../../data/repositories/banners_repository.dart';
import '../../data/repositories/blocked_dates_repository.dart';
import '../../data/repositories/bookings_repository.dart';
import '../../data/repositories/branches_repository.dart';
import '../../data/repositories/categories_repository.dart';
import '../../data/repositories/classes_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/instructors_repository.dart';
import '../../data/repositories/members_repository.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../data/repositories/packages_repository.dart';
import '../../data/repositories/reports_repository.dart';
import '../../data/repositories/sessions_repository.dart';
import '../../data/repositories/staff_repository.dart';
import '../../data/repositories/transactions_repository.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final functionsProvider = Provider<FirebaseFunctions>((ref) => FirebaseFunctions.instance);
final authProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final classesRepositoryProvider = Provider(
  (ref) => ClassesRepository(ref.watch(firestoreProvider), ref.watch(authProvider), ref.watch(functionsProvider)),
);
final sessionsRepositoryProvider = Provider(
  (ref) => SessionsRepository(ref.watch(firestoreProvider), ref.watch(authProvider), ref.watch(functionsProvider)),
);
final bannersRepositoryProvider = Provider(
  (ref) => BannersRepository(ref.watch(firestoreProvider), ref.watch(authProvider), ref.watch(functionsProvider)),
);
final packagesRepositoryProvider = Provider(
  (ref) => PackagesRepository(ref.watch(firestoreProvider), ref.watch(authProvider), ref.watch(functionsProvider)),
);
final appSettingsRepositoryProvider = Provider(
  (ref) => AppSettingsRepository(ref.watch(firestoreProvider), ref.watch(authProvider), ref.watch(functionsProvider)),
);
final instructorsRepositoryProvider = Provider(
  (ref) => InstructorsRepository(ref.watch(firestoreProvider), ref.watch(authProvider), ref.watch(functionsProvider)),
);
final branchesRepositoryProvider = Provider((ref) => BranchesRepository(ref.watch(firestoreProvider)));
final membersRepositoryProvider = Provider(
  (ref) => MembersRepository(ref.watch(firestoreProvider), ref.watch(authProvider), ref.watch(functionsProvider)),
);
final transactionsRepositoryProvider = Provider(
  (ref) =>
      TransactionsRepository(ref.watch(firestoreProvider), ref.watch(authProvider), ref.watch(functionsProvider)),
);
final notificationsRepositoryProvider = Provider((ref) => NotificationsRepository(ref.watch(firestoreProvider)));
final bookingsRepositoryProvider = Provider((ref) => BookingsRepository(ref.watch(firestoreProvider)));
final staffRepositoryProvider =
    Provider((ref) => StaffRepository(ref.watch(firestoreProvider), ref.watch(functionsProvider)));
final categoriesRepositoryProvider = Provider(
  (ref) => CategoriesRepository(ref.watch(firestoreProvider), ref.watch(authProvider), ref.watch(functionsProvider)),
);
final blockedDatesRepositoryProvider = Provider(
  (ref) =>
      BlockedDatesRepository(ref.watch(firestoreProvider), ref.watch(authProvider), ref.watch(functionsProvider)),
);
final dashboardRepositoryProvider = Provider((ref) => DashboardRepository(ref.watch(firestoreProvider)));
final reportsRepositoryProvider = Provider((ref) => ReportsRepository(ref.watch(firestoreProvider)));
