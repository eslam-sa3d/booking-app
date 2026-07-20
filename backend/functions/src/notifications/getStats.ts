import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "../lib/admin";

interface GetNotificationStatsRequest {
  notificationId: string;
}

/**
 * Delivery/read counters for a broadcast, derived from the
 * `users/{uid}/inbox/{id}` copies that `notifyUsers` fan-out writes (each
 * tagged with `sourceNotificationId`). Routed through a callable (Admin SDK,
 * bypasses rules) rather than a client-side collectionGroup query: granting
 * staff broad read access across every customer's inbox subcollection is a
 * bigger client-side permission surface than this feature needs, and
 * Firestore's security rules don't reliably authorize an OR of a
 * wildcard-bound condition (isOwner(uid)) and a wildcard-independent one
 * (isStaff()) for collectionGroup list queries.
 */
export const getNotificationStats = onCall<GetNotificationStatsRequest>(async (request) => {
  const role = request.auth?.token?.role as string | undefined;
  if (!request.auth || (role !== "staff" && role !== "admin")) {
    throw new HttpsError("permission-denied", "Only staff or admin may view delivery stats.");
  }

  const { notificationId } = request.data;
  if (!notificationId) {
    throw new HttpsError("invalid-argument", "Missing notificationId.");
  }

  const snap = await db
    .collectionGroup("inbox")
    .where("sourceNotificationId", "==", notificationId)
    .get();
  const read = snap.docs.filter((d) => d.data().isRead === true).length;

  return { delivered: snap.docs.length, read };
});
