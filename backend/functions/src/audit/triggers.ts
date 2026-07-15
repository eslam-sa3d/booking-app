import { auditedCollectionTrigger } from "../lib/audit";

// One exported Cloud Function per audited collection — every admin write to
// these (create/update) must include an `updatedBy` field (enforced by
// firestore.rules to equal the real caller's uid), which becomes the
// auditLog entry's actor. Deletes are logged separately by `adminDelete`.
export const auditClasses = auditedCollectionTrigger("classes/{docId}", "classes");
export const auditSessions = auditedCollectionTrigger("sessions/{docId}", "sessions");
export const auditBanners = auditedCollectionTrigger("banners/{docId}", "banners");
export const auditPackages = auditedCollectionTrigger("packages/{docId}", "packages");
export const auditInstructors = auditedCollectionTrigger("instructors/{docId}", "instructors");
export const auditCategories = auditedCollectionTrigger("categories/{docId}", "categories");
export const auditBlockedDates = auditedCollectionTrigger("blockedDates/{docId}", "blockedDates");
export const auditAppSettings = auditedCollectionTrigger("appSettings/{docId}", "appSettings");
export const auditTransactions = auditedCollectionTrigger("transactions/{docId}", "transactions");
// Most `users/{uid}` writes are customers self-editing their own profile
// (no `updatedBy`, nothing to audit); this only captures staff-initiated
// changes like suspend/reactivate, which the admin dashboard tags.
export const auditMembers = auditedCollectionTrigger("users/{docId}", "users", { alwaysExpectActor: false });
