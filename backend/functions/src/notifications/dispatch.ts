import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { getMessaging } from "firebase-admin/messaging";
import { db } from "../lib/admin";
import type { NotificationDef, InboxNotification } from "../models/types";

/**
 * Fires when staff compose a broadcast in the admin dashboard's
 * Notification Center (a new `notifications/{id}` doc). Resolves the
 * target audience, writes an inbox copy for each recipient, and best-effort
 * sends an FCM push to any device tokens on file — a missing/invalid token
 * never blocks the inbox write, since the inbox is the durable record.
 */
export const dispatchNotification = onDocumentCreated("notifications/{notificationId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;
  const definition = snapshot.data() as NotificationDef;

  const targetUids = await resolveTargetUids(definition);
  if (targetUids.length === 0) {
    logger.warn(`dispatchNotification: no recipients resolved for ${snapshot.id}`, { target: definition.target });
    return;
  }

  const inboxBatchSize = 400; // stay under Firestore's 500-write batch limit
  const tokens: string[] = [];

  for (let i = 0; i < targetUids.length; i += inboxBatchSize) {
    const batch = db.batch();
    const slice = targetUids.slice(i, i + inboxBatchSize);
    for (const uid of slice) {
      const inboxRef = db.collection("users").doc(uid).collection("inbox").doc();
      const entry: InboxNotification = {
        id: inboxRef.id,
        sourceNotificationId: snapshot.id,
        type: definition.type,
        title: definition.title,
        titleAr: definition.titleAr,
        body: definition.body,
        bodyAr: definition.bodyAr,
        createdAt: definition.createdAt,
        isRead: false,
        relatedBookingId: null,
      };
      batch.set(inboxRef, entry);
    }
    await batch.commit();
  }

  const userDocs = await db.getAll(...targetUids.map((uid) => db.collection("users").doc(uid)));
  for (const doc of userDocs) {
    const userTokens = (doc.data()?.fcmTokens as string[] | undefined) ?? [];
    tokens.push(...userTokens);
  }

  if (tokens.length > 0) {
    try {
      const response = await getMessaging().sendEachForMulticast({
        tokens,
        notification: { title: definition.title, body: definition.body },
        data: { type: definition.type, notificationId: snapshot.id },
      });
      logger.info(`dispatchNotification: sent to ${response.successCount}/${tokens.length} tokens for ${snapshot.id}`);
    } catch (err) {
      logger.error("dispatchNotification: FCM send failed", err);
    }
  }

  await snapshot.ref.update({ status: "sent" });
});

async function resolveTargetUids(definition: NotificationDef): Promise<string[]> {
  if (definition.target === "user" && definition.targetUserId) {
    return [definition.targetUserId];
  }
  if (definition.target === "segment") {
    // TODO(future): real segment definitions (e.g. "package expiring this
    // week", "no booking in 30 days"). Falls back to all customers today.
    logger.warn(`dispatchNotification: segment targeting not yet implemented, falling back to all customers (segment=${definition.targetSegment})`);
  }
  const snap = await db.collection("users").where("role", "==", "customer").get();
  return snap.docs.map((d) => d.id);
}
