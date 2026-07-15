export { onUserCreate } from "./auth/onUserCreate";
export { assignStaffRole } from "./auth/assignStaffRole";

export { onBookingCreate } from "./bookings/onBookingCreate";
export { onBookingCancel } from "./bookings/onBookingCancel";

// Stubs — signatures only, implemented in the next build-order phase.
export { paymentWebhook } from "./payments/webhook";
export { dispatchNotification } from "./notifications/dispatch";
export { packageExpiryReminders } from "./scheduled/packageExpiryReminders";
