import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import { Timestamp } from "firebase-admin/firestore";
import { db } from "../lib/admin";
import { notifyUsers } from "../lib/notify";
import type { NotificationDef } from "../models/types";

/**
 * Fires when staff compose a broadcast in the admin dashboard's
 * Notification Center. A "send now" compose is created with
 * status: 'sent' and dispatches immediately; a "schedule for later" compose
 * is created with status: 'scheduled' and is picked up by
 * `dispatchScheduledNotifications` instead once its time comes.
 */
export const onNotificationCreated = onDocumentCreated("notifications/{notificationId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;
  const definition = snapshot.data() as NotificationDef;
  if (definition.status === "scheduled") return;
  await performDispatch(snapshot.id, definition);
});

/** Runs every 15 minutes, sending any broadcast whose scheduled time has arrived. */
export const dispatchScheduledNotifications = onSchedule("every 15 minutes", async () => {
  const now = Timestamp.now();
  const snap = await db
    .collection("notifications")
    .where("status", "==", "scheduled")
    .where("scheduledFor", "<=", now)
    .get();
  if (snap.empty) return;

  for (const doc of snap.docs) {
    await performDispatch(doc.id, doc.data() as NotificationDef);
  }
  logger.info(`dispatchScheduledNotifications: dispatched ${snap.size} scheduled notification(s)`);
});

async function performDispatch(notificationId: string, definition: NotificationDef): Promise<void> {
  const targetUids = await resolveTargetUids(definition);
  if (targetUids.length === 0) {
    logger.warn(`performDispatch: no recipients resolved for ${notificationId}`, { target: definition.target });
    await db.collection("notifications").doc(notificationId).update({ status: "sent" });
    return;
  }

  await notifyUsers(targetUids, {
    type: definition.type,
    title: definition.title,
    titleAr: definition.titleAr,
    body: definition.body,
    bodyAr: definition.bodyAr,
    sourceNotificationId: notificationId,
  });

  await db.collection("notifications").doc(notificationId).update({ status: "sent" });
}

async function resolveTargetUids(definition: NotificationDef): Promise<string[]> {
  if (definition.target === "user" && definition.targetUserId) {
    return [definition.targetUserId];
  }
  if (definition.target === "segment" && definition.targetSegment) {
    return resolveSegment(definition.targetSegment);
  }
  const snap = await db.collection("users").where("role", "==", "customer").get();
  return snap.docs.map((d) => d.id);
}

const SEVEN_DAYS_MS = 7 * 24 * 60 * 60 * 1000;
const THIRTY_DAYS_MS = 30 * 24 * 60 * 60 * 1000;

/**
 * Named segments the admin dashboard's Notification Center can target.
 * Both are computed live from existing data rather than a stored
 * membership list, so they always reflect the current state.
 */
async function resolveSegment(segment: string): Promise<string[]> {
  if (segment === "expiringPackageThisWeek") {
    const now = Timestamp.now();
    const in7Days = Timestamp.fromMillis(now.toMillis() + SEVEN_DAYS_MS);
    const snap = await db
      .collectionGroup("packages")
      .where("status", "==", "active")
      .where("expiresAt", ">", now)
      .where("expiresAt", "<=", in7Days)
      .get();
    return [...new Set(snap.docs.map((d) => d.data().userId as string))];
  }

  if (segment === "noBookingInLast30Days") {
    const cutoff = Timestamp.fromMillis(Date.now() - THIRTY_DAYS_MS);
    const [customersSnap, recentBookingsSnap] = await Promise.all([
      db.collection("users").where("role", "==", "customer").get(),
      db.collection("bookings").where("createdAt", ">=", cutoff).get(),
    ]);
    const recentUids = new Set(recentBookingsSnap.docs.map((d) => d.data().userId as string));
    return customersSnap.docs.map((d) => d.id).filter((uid) => !recentUids.has(uid));
  }

  logger.warn(`resolveSegment: unknown segment "${segment}", falling back to all customers`);
  const snap = await db.collection("users").where("role", "==", "customer").get();
  return snap.docs.map((d) => d.id);
}
