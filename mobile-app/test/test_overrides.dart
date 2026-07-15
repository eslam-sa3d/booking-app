import 'package:booking_app/core/providers/repository_providers.dart';
import 'package:booking_app/data/datasources/firebase/firebase_app_settings_repository.dart' show appSettingsRepositoryProvider;
import 'package:booking_app/data/datasources/mock/mock_app_settings_repository.dart';
import 'package:booking_app/data/datasources/mock/mock_auth_repository.dart';
import 'package:booking_app/data/datasources/mock/mock_banner_repository.dart';
import 'package:booking_app/data/datasources/mock/mock_booking_repository.dart';
import 'package:booking_app/data/datasources/mock/mock_class_repository.dart';
import 'package:booking_app/data/datasources/mock/mock_family_repository.dart';
import 'package:booking_app/data/datasources/mock/mock_notification_repository.dart';
import 'package:booking_app/data/datasources/mock/mock_package_repository.dart';
import 'package:booking_app/data/datasources/mock/mock_payment_repository.dart';
import 'package:booking_app/data/datasources/mock/mock_review_repository.dart';

/// Widget/integration tests run against the in-memory mock data layer
/// instead of a live Firebase connection — apply these on top of the
/// sharedPreferencesProvider override when pumping [SwimAcademyApp].
final testRepositoryOverrides = [
  authRepositoryProvider.overrideWithValue(MockAuthRepository()),
  classRepositoryProvider.overrideWithValue(MockClassRepository()),
  bookingRepositoryProvider.overrideWithValue(MockBookingRepository()),
  familyRepositoryProvider.overrideWithValue(MockFamilyRepository()),
  packageRepositoryProvider.overrideWithValue(MockPackageRepository()),
  paymentRepositoryProvider.overrideWithValue(MockPaymentRepository()),
  paymentServiceProvider.overrideWithValue(MockPaymentService()),
  notificationRepositoryProvider.overrideWithValue(MockNotificationRepository()),
  reviewRepositoryProvider.overrideWithValue(MockReviewRepository()),
  bannerRepositoryProvider.overrideWithValue(MockBannerRepository()),
  appSettingsRepositoryProvider.overrideWithValue(MockAppSettingsRepository()),
];
