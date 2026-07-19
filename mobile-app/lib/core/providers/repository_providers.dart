import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firebase/firebase_auth_repository.dart';
import '../../data/datasources/firebase/firebase_banner_repository.dart';
import '../../data/datasources/firebase/firebase_booking_repository.dart';
import '../../data/datasources/firebase/firebase_class_repository.dart';
import '../../data/datasources/firebase/firebase_family_repository.dart';
import '../../data/datasources/firebase/firebase_notification_repository.dart';
import '../../data/datasources/firebase/firebase_package_repository.dart';
import '../../data/datasources/firebase/firebase_payment_repository.dart';
import '../../data/datasources/firebase/firebase_review_repository.dart';
import '../../data/datasources/mock/mock_payment_repository.dart' show MockPaymentService;
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/banner_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/class_repository.dart';
import '../../data/repositories/family_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/package_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/review_repository.dart';

/// Live Firebase SDK singletons. Overridden with fakes only in widget
/// tests that don't want to touch a real emulator; every screen just
/// reads through the repository providers below, never these directly.
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseAuthProvider = Provider<fb_auth.FirebaseAuth>((ref) => fb_auth.FirebaseAuth.instance);
final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) => FirebaseFunctions.instance);

/// Every provider below exposes the abstract repository type — tests
/// override individual providers with their Mock* counterpart (see
/// test/test_utils.dart) rather than the whole app switching modes, so
/// production always talks to the real backend while tests stay hermetic.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(ref.watch(firebaseAuthProvider), ref.watch(firebaseFirestoreProvider)),
);
final classRepositoryProvider = Provider<ClassRepository>(
  (ref) => FirebaseClassRepository(ref.watch(firebaseFirestoreProvider)),
);
final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => FirebaseBookingRepository(ref.watch(firebaseFirestoreProvider)),
);
final familyRepositoryProvider = Provider<FamilyRepository>(
  (ref) => FirebaseFamilyRepository(ref.watch(firebaseFirestoreProvider)),
);
final packageRepositoryProvider = Provider<PackageRepository>(
  (ref) => FirebasePackageRepository(ref.watch(firebaseFirestoreProvider), ref.watch(firebaseFunctionsProvider)),
);
final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => FirebasePaymentRepository(ref.watch(firebaseFirestoreProvider)),
);
// No real payment gateway is wired up yet (see backend/functions/src/payments/webhook.ts) —
// this simulates a charge locally regardless of mock/real backend mode.
final paymentServiceProvider = Provider<PaymentService>((ref) => MockPaymentService());
final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => FirebaseNotificationRepository(ref.watch(firebaseFirestoreProvider)),
);
final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => FirebaseReviewRepository(ref.watch(firebaseFirestoreProvider)),
);
final bannerRepositoryProvider = Provider<BannerRepository>(
  (ref) => FirebaseBannerRepository(ref.watch(firebaseFirestoreProvider)),
);
