import '../../models/models.dart';
import 'mock_seed_data.dart';

/// Single in-memory "database" shared by every Mock*Repository so that
/// bookings, family members, packages, payments etc. stay consistent across
/// the app for the lifetime of the process. Replace this whole file with
/// real Firestore/REST calls when wiring a real backend.
class MockDatabase {
  MockDatabase._internal() {
    _seed();
  }

  static final MockDatabase instance = MockDatabase._internal();

  final Map<String, AppUser> users = {};
  final Map<String, String> passwordsByEmail = {};
  final List<FamilyMember> familyMembers = [];
  late List<SwimSession> sessions;
  final List<Booking> bookings = [];
  final List<UserPackage> userPackages = [];
  final List<Payment> payments = [];
  final List<AppNotification> notifications = [];
  final List<Review> reviews = [];

  int _idCounter = 1000;
  String nextId(String prefix) => '$prefix${_idCounter++}';

  void _seed() {
    sessions = MockSeedData.generateSessions();

    const demoUserId = 'u1';
    users[demoUserId] = AppUser(
      id: demoUserId,
      name: 'Eslam Saad',
      email: 'eslamsa3d@hotmail.com',
      phone: '+966500000000',
      preferredLanguage: 'en',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    );
    passwordsByEmail['eslamsa3d@hotmail.com'] = 'password123';

    familyMembers.addAll([
      FamilyMember(
        id: 'f1',
        userId: demoUserId,
        name: 'Yousef',
        dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 7)),
        gender: Gender.male,
        swimmingLevel: 2,
        badges: [
          SwimBadge(
            id: 'bd1',
            title: 'Water Confidence',
            titleAr: 'الثقة في الماء',
            iconName: 'water_drop',
            earnedAt: DateTime.now().subtract(const Duration(days: 40)),
          ),
        ],
        progressNotes: [
          ProgressNote(
            id: 'pn1',
            note: 'Great progress on backstroke this week!',
            noteAr: 'تقدم رائع في سباحة الظهر هذا الأسبوع!',
            instructorName: 'Lina Youssef',
            date: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ],
      ),
      FamilyMember(
        id: 'f2',
        userId: demoUserId,
        name: 'Layla',
        dateOfBirth: DateTime.now().subtract(const Duration(days: 365 * 5)),
        gender: Gender.female,
        swimmingLevel: 1,
      ),
    ]);

    userPackages.add(
      UserPackage(
        id: 'up1',
        userId: demoUserId,
        packageId: 'p1',
        purchasedAt: DateTime.now().subtract(const Duration(days: 10)),
        expiresAt: DateTime.now().add(const Duration(days: 50)),
        sessionsRemaining: 5,
      ),
    );

    payments.add(
      Payment(
        id: 'pay1',
        userId: demoUserId,
        amount: 1100,
        method: PaymentMethod.mada,
        status: PaymentStatus.succeeded,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        description: '8-Session Pack purchase',
        descriptionAr: 'شراء باقة 8 حصص',
        relatedPackageId: 'p1',
      ),
    );

    final firstUpcoming = sessions.firstWhere((s) => !s.isPast && s.spotsLeft > 0);
    bookings.add(
      Booking(
        id: 'bk1',
        userId: demoUserId,
        sessionId: firstUpcoming.id,
        participantId: 'f1',
        participantName: 'Yousef',
        status: BookingStatus.confirmed,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    );
    final idx = sessions.indexWhere((s) => s.id == firstUpcoming.id);
    sessions[idx] = sessions[idx].copyWith(bookedCount: sessions[idx].bookedCount + 1);

    notifications.addAll([
      AppNotification(
        id: 'n1',
        userId: demoUserId,
        type: NotificationType.bookingConfirmed,
        title: 'Booking confirmed',
        titleAr: 'تم تأكيد الحجز',
        body: 'Your booking for Yousef is confirmed.',
        bodyAr: 'تم تأكيد حجزك ليوسف.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isRead: false,
        relatedBookingId: 'bk1',
      ),
      AppNotification(
        id: 'n2',
        userId: demoUserId,
        type: NotificationType.promotion,
        title: 'Summer offer: 20% off Monthly Unlimited',
        titleAr: 'عرض الصيف: خصم 20% على الاشتراك الشهري',
        body: 'Limited time offer on our most popular package.',
        bodyAr: 'عرض لفترة محدودة على أكثر باقاتنا شعبية.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ]);
  }
}
