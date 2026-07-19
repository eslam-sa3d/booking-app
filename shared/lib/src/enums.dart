enum ClassCategory {
  kids,
  adults,
  beginner,
  intermediate,
  advanced,
  private,
  ladiesOnly;

  static ClassCategory fromName(String name) =>
      ClassCategory.values.firstWhere((e) => e.name == name, orElse: () => ClassCategory.beginner);
}

enum BookingStatus {
  // Transient client-written sentinel while onBookingCreate finalizes the
  // real status — never a value the UI should render as a success state.
  pending,
  confirmed,
  waitlisted,
  cancelled,
  completed;

  static BookingStatus fromName(String name) =>
      BookingStatus.values.firstWhere((e) => e.name == name, orElse: () => BookingStatus.pending);
}

enum PackageType {
  sessionPack,
  monthlyUnlimited,
  privateLessons;

  static PackageType fromName(String name) =>
      PackageType.values.firstWhere((e) => e.name == name, orElse: () => PackageType.sessionPack);
}

enum UserPackageStatus {
  active,
  expired,
  cancelled;

  static UserPackageStatus fromName(String name) =>
      UserPackageStatus.values.firstWhere((e) => e.name == name, orElse: () => UserPackageStatus.active);
}

enum PaymentStatus {
  pending,
  succeeded,
  failed,
  refunded;

  static PaymentStatus fromName(String name) =>
      PaymentStatus.values.firstWhere((e) => e.name == name, orElse: () => PaymentStatus.pending);
}

enum NotificationType {
  bookingConfirmed,
  waitlisted,
  reminder,
  cancellation,
  waitlistPromoted,
  packageExpiry,
  promotion,
  general,
  refundResolved;

  static NotificationType fromName(String name) =>
      NotificationType.values.firstWhere((e) => e.name == name, orElse: () => NotificationType.general);
}

enum RefundRequestStatus {
  pending,
  approved,
  denied;

  static RefundRequestStatus fromName(String name) => RefundRequestStatus.values
      .firstWhere((e) => e.name == name, orElse: () => RefundRequestStatus.pending);
}

enum Gender {
  male,
  female;

  static Gender fromName(String name) => Gender.values.firstWhere((e) => e.name == name, orElse: () => Gender.male);
}
