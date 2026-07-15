import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/mock/mock_auth_repository.dart';
import '../../data/datasources/mock/mock_booking_repository.dart';
import '../../data/datasources/mock/mock_class_repository.dart';
import '../../data/datasources/mock/mock_family_repository.dart';
import '../../data/datasources/mock/mock_notification_repository.dart';
import '../../data/datasources/mock/mock_package_repository.dart';
import '../../data/datasources/mock/mock_payment_repository.dart';
import '../../data/datasources/mock/mock_review_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/class_repository.dart';
import '../../data/repositories/family_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/package_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/review_repository.dart';

/// Every provider below exposes the abstract repository type. Swapping mock
/// data for a real backend later means changing only the implementation
/// constructed here (e.g. `MockAuthRepository()` -> `FirebaseAuthRepository()`).
final authRepositoryProvider = Provider<AuthRepository>((ref) => MockAuthRepository());
final classRepositoryProvider = Provider<ClassRepository>((ref) => MockClassRepository());
final bookingRepositoryProvider = Provider<BookingRepository>((ref) => MockBookingRepository());
final familyRepositoryProvider = Provider<FamilyRepository>((ref) => MockFamilyRepository());
final packageRepositoryProvider = Provider<PackageRepository>((ref) => MockPackageRepository());
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) => MockPaymentRepository());
final paymentServiceProvider = Provider<PaymentService>((ref) => MockPaymentService());
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) => MockNotificationRepository());
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) => MockReviewRepository());
