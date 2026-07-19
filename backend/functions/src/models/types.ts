/**
 * Firestore schema, mirrored field-for-field from the Dart models in
 * shared/lib/src/*.dart. Cloud Functions can't import Dart directly, so
 * this file is the TypeScript side of that contract — keep the two in
 * sync by hand whenever a model changes.
 */

export type Role = "customer" | "staff" | "admin";

export type Gender = "male" | "female";

export interface NotificationPreferences {
  reminders: boolean;
  promotions: boolean;
  announcements: boolean;
}

/** users/{uid} */
export interface AppUser {
  id: string;
  name: string;
  email: string;
  phone: string;
  photoUrl?: string | null;
  preferredLanguage: "en" | "ar";
  role: Role;
  suspended: boolean;
  notificationPreferences?: NotificationPreferences;
  createdAt: FirebaseFirestore.Timestamp;
}

/** users/{uid}/familyMembers/{id} */
export interface FamilyMember {
  id: string;
  userId: string;
  name: string;
  dateOfBirth: FirebaseFirestore.Timestamp;
  gender: Gender;
  medicalNotes: string;
  swimmingLevel: number; // 1-5
  photoUrl?: string | null;
  badges: SwimBadge[];
  progressNotes: ProgressNote[];
}

export interface SwimBadge {
  id: string;
  title: string;
  titleAr: string;
  iconName: string;
  earnedAt: FirebaseFirestore.Timestamp;
}

export interface ProgressNote {
  id: string;
  note: string;
  noteAr: string;
  instructorName: string;
  date: FirebaseFirestore.Timestamp;
}

export type ClassCategory =
  | "kids"
  | "adults"
  | "beginner"
  | "intermediate"
  | "advanced"
  | "private"
  | "ladiesOnly";

/** classes/{id} — catalog, staff/admin managed */
export interface SwimClass {
  id: string;
  title: string;
  titleAr: string;
  description: string;
  descriptionAr: string;
  // References categories/{id} docs — kept as free-form strings (not the
  // ClassCategory union) so admin can add/rename/remove categories at
  // runtime without a code change. The 7 ClassCategory values above are
  // the seeded starter set, not a closed set going forward.
  categories: string[];
  durationMinutes: number;
  price: number;
  currency: string;
  instructorId: string;
  branchId: string;
  rating: number;
  reviewCount: number;
  // Placeholder card art (no real image upload pipeline yet) — a brand
  // color + a Material icon name, not a hosted image.
  heroColorHex: string;
  heroIcon: string;
}

/** sessions/{id} — a bookable occurrence of a class */
export interface SwimSession {
  id: string;
  classId: string;
  date: FirebaseFirestore.Timestamp;
  startMinutes: number;
  endMinutes: number;
  capacity: number;
  bookedCount: number;
  waitlistCount: number;
  instructorId: string;
  branchId: string;
}

// "pending" is a transient client-written sentinel while onBookingCreate
// finalizes the real status — never a value business logic should treat
// as a success state.
export type BookingStatus = "pending" | "confirmed" | "waitlisted" | "cancelled" | "completed";

/** bookings/{id} */
export interface Booking {
  id: string;
  userId: string;
  sessionId: string;
  participantId: string;
  participantName: string;
  status: BookingStatus;
  createdAt: FirebaseFirestore.Timestamp;
  isRecurring: boolean;
  recurrenceGroupId?: string | null;
  cancelledAt?: FirebaseFirestore.Timestamp | null;
  cancellationReason?: string | null;
  reviewed: boolean;
  // Set server-side by onBookingCreate when a confirmed booking draws a
  // session credit from one of the user's own active sessionPack packages;
  // null when paid for standalone (or when no package with sessions
  // remaining was available). onBookingCancel refunds the credit here.
  userPackageId?: string | null;
}

export type PackageType = "sessionPack" | "monthlyUnlimited" | "privateLessons";

/** packages/{id} — catalog */
export interface SwimPackage {
  id: string;
  name: string;
  nameAr: string;
  description: string;
  descriptionAr: string;
  type: PackageType;
  sessionCount?: number | null; // null = unlimited
  validityDays: number;
  price: number;
  currency: string;
  isPopular: boolean;
}

export type UserPackageStatus = "active" | "expired" | "cancelled";

/** users/{uid}/packages/{id} — owned instances */
export interface UserPackage {
  id: string;
  userId: string;
  packageId: string;
  purchasedAt: FirebaseFirestore.Timestamp;
  expiresAt: FirebaseFirestore.Timestamp;
  sessionsRemaining?: number | null;
  status: UserPackageStatus;
}

export type PaymentStatus = "pending" | "succeeded" | "failed" | "refunded";
// References a paymentMethods/{id} doc id — CMS-configured by admins (see
// PaymentMethodConfig below), not a fixed set of gateway method codes.
export type PaymentMethod = string;

/** paymentMethods/{id} — admin-configured checkout options */
export interface PaymentMethodConfig {
  id: string;
  nameEn: string;
  nameAr: string;
  order: number;
  isActive: boolean;
  logoUrl?: string | null;
  paymentLinkUrl?: string | null;
}

export type RefundRequestStatus = "pending" | "approved" | "denied";

/** transactions/{id} */
export interface Transaction {
  id: string;
  userId: string;
  amount: number;
  currency: string;
  method: PaymentMethod;
  status: PaymentStatus;
  createdAt: FirebaseFirestore.Timestamp;
  description: string;
  descriptionAr: string;
  relatedPackageId?: string | null;
  relatedBookingId?: string | null;
  gatewayReference?: string | null;
  receiptNumber?: string | null;
  refundRequestStatus?: RefundRequestStatus | null;
  refundRequestedAt?: FirebaseFirestore.Timestamp | null;
  refundRequestReason?: string | null;
  refundResolvedBy?: string | null;
}

/** reviews/{id} */
export interface Review {
  id: string;
  userId: string;
  userName: string;
  // References the caller's own completed bookings/{id} for this
  // sessionId — firestore.rules verifies this at create time so a review
  // can't be left for a class the user never actually attended.
  bookingId: string;
  sessionId: string;
  classId: string;
  instructorId: string;
  rating: number; // 1-5
  comment: string;
  createdAt: FirebaseFirestore.Timestamp;
}

/** banners/{id} */
export interface Banner {
  id: string;
  title: string;
  titleAr: string;
  subtitle: string;
  subtitleAr: string;
  imageUrl: string;
  linkAction?: string | null; // e.g. "class:{id}" or "packages"
  order: number;
  isActive: boolean;
  startDate?: FirebaseFirestore.Timestamp | null;
  endDate?: FirebaseFirestore.Timestamp | null;
}

/** instructors/{id} */
export interface Instructor {
  id: string;
  name: string;
  nameAr: string;
  bio: string;
  bioAr: string;
  photoUrl?: string | null;
  rating: number;
  specialties: string[];
}

/** categories/{id} — admin-managed taxonomy used to tag classes */
export interface CategoryDef {
  id: string;
  nameEn: string;
  nameAr: string;
  order: number;
}

/** blockedDates/{id} — a date (optionally scoped to one branch) closed to new sessions/bookings */
export interface BlockedDate {
  id: string;
  date: FirebaseFirestore.Timestamp;
  branchId?: string | null; // null = all branches
  reason: string;
  createdBy: string;
  createdAt: FirebaseFirestore.Timestamp;
}

/** branches/{id} */
export interface Branch {
  id: string;
  name: string;
  nameAr: string;
  address: string;
  addressAr: string;
  // A bundled local asset path (no branch photo upload pipeline yet), e.g.
  // 'assets/images/branch_placeholder.png' — not a hosted image URL.
  imageAsset: string;
}

export type NotificationType =
  | "bookingConfirmed"
  | "waitlisted"
  | "reminder"
  | "cancellation"
  | "waitlistPromoted"
  | "packageExpiry"
  | "promotion"
  | "general"
  | "refundResolved";

/** notifications/{id} — staff-authored broadcast/definition */
export interface NotificationDef {
  id: string;
  type: NotificationType;
  title: string;
  titleAr: string;
  body: string;
  bodyAr: string;
  target: "all" | "segment" | "user";
  targetUserId?: string | null;
  targetSegment?: string | null;
  scheduledFor?: FirebaseFirestore.Timestamp | null;
  createdAt: FirebaseFirestore.Timestamp;
  createdBy: string; // staff uid
  status: "draft" | "scheduled" | "sent";
}

/** users/{uid}/inbox/{id} — per-user delivered copy */
export interface InboxNotification {
  id: string;
  sourceNotificationId?: string | null;
  type: NotificationType;
  title: string;
  titleAr: string;
  body: string;
  bodyAr: string;
  createdAt: FirebaseFirestore.Timestamp;
  isRead: boolean;
  relatedBookingId?: string | null;
}

/** appSettings/config — singleton doc */
export interface AppSettings {
  brandPrimaryColorHex: string;
  logoUrl?: string | null;
  faqEn: { question: string; answer: string }[];
  faqAr: { question: string; answer: string }[];
  termsUrl?: string | null;
  privacyUrl?: string | null;
  whatsappNumber?: string | null;
  contactEmail?: string | null;
}

/** auditLog/{id} — server-write only */
export interface AuditLogEntry {
  id: string;
  actorUid: string;
  action: string;
  targetCollection: string;
  targetId: string;
  before?: unknown;
  after?: unknown;
  createdAt: FirebaseFirestore.Timestamp;
}
