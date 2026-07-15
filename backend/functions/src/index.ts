export { onUserCreate } from "./auth/onUserCreate";
export { assignStaffRole } from "./auth/assignStaffRole";

export { onBookingCreate } from "./bookings/onBookingCreate";
export { onBookingCancel } from "./bookings/onBookingCancel";

// Stub — real gateway integration deferred (see docs/architecture.md).
export { paymentWebhook } from "./payments/webhook";

export { onNotificationCreated, dispatchScheduledNotifications } from "./notifications/dispatch";
export { packageExpiryReminders } from "./scheduled/packageExpiryReminders";
export { sessionReminders } from "./scheduled/sessionReminders";

export { adminDelete } from "./admin/adminDelete";

export {
  auditClasses,
  auditSessions,
  auditBanners,
  auditPackages,
  auditInstructors,
  auditCategories,
  auditBlockedDates,
  auditAppSettings,
  auditTransactions,
  auditMembers,
} from "./audit/triggers";
