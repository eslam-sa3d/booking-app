/**
 * Firestore schema, mirrored field-for-field from the Dart models in
 * shared/lib/src/*.dart. Cloud Functions can't import Dart directly, so
 * this file is the TypeScript side of that contract — keep the two in
 * sync by hand whenever a model changes.
 */

export type Role = "customer" | "staff" | "admin";

export type Gender = "male" | "female";

/** users/{uid} */
export interface AppUser {
  id: string;
  name: string;
  email: string;
  phone: string;
  photoUrl?: string | null;
  preferredLanguage: "en" | "ar";
  role: Role;
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
  categories: ClassCategory[];
  durationMinutes: number;
  price: number;
  currency: string;
  instructorId: string;
  branchId: string;
  rating: number;
  reviewCount: number;
  heroImageUrl?: string | null;
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

export type BookingStatus = "confirmed" | "waitlisted" | "cancelled" | "completed";

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
export type PaymentMethod = "mada" | "applePay" | "stcPay" | "creditCard";

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
  gatewayReference?: string | null;
}

/** reviews/{id} */
export interface Review {
  id: string;
  userId: string;
  userName: string;
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

/** branches/{id} */
export interface Branch {
  id: string;
  name: string;
  nameAr: string;
  address: string;
  addressAr: string;
  imageUrl?: string | null;
}

export type NotificationType =
  | "bookingConfirmed"
  | "reminder"
  | "cancellation"
  | "waitlistPromoted"
  | "packageExpiry"
  | "promotion"
  | "general";

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
