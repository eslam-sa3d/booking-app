import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";

/**
 * TODO(next phase): fires when staff compose a broadcast in the admin
 * dashboard's Notification Center (a new `notifications/{id}` doc).
 *
 * Will: resolve `target` ('all' | 'segment' | 'user') to a list of uids,
 * write an `InboxNotification` copy into each target's
 * `users/{uid}/inbox/{id}` (same shape onBookingCreate/onBookingCancel
 * already write), look up each user's FCM device token(s), and send via
 * firebase-admin's messaging API — respecting each user's per-category
 * notification preferences once those are added to the user profile.
 */
export const dispatchNotification = onDocumentCreated("notifications/{notificationId}", async (event) => {
  logger.warn("dispatchNotification triggered but not yet implemented", {
    notificationId: event.params.notificationId,
  });
});
