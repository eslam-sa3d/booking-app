import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import { Timestamp } from "firebase-admin/firestore";
import { db } from "../lib/admin";
import type { UserPackage, InboxNotification } from "../models/types";

const REMINDER_WINDOW_DAYS = 3;

/**
 * Runs daily. Finds active packages expiring within REMINDER_WINDOW_DAYS
 * and sends one reminder each — a `sentPackageExpiryReminders/{userPackageId}`
 * marker doc (rather than a field on the package itself) tracks who's
 * already been notified, so re-running this function is always safe.
 */
export const packageExpiryReminders = onSchedule("every day 09:00", async () => {
  const now = Timestamp.now();
  const windowEnd = Timestamp.fromMillis(now.toMillis() + REMINDER_WINDOW_DAYS * 24 * 60 * 60 * 1000);

  const snap = await db
    .collectionGroup("packages")
    .where("status", "==", "active")
    .where("expiresAt", ">=", now)
    .where("expiresAt", "<=", windowEnd)
    .get();

  if (snap.empty) {
    logger.info("packageExpiryReminders: nothing expiring in the next " + REMINDER_WINDOW_DAYS + " days");
    return;
  }

  let sentCount = 0;
  for (const doc of snap.docs) {
    const userPackage = doc.data() as UserPackage;
    const markerRef = db.collection("sentPackageExpiryReminders").doc(userPackage.id);
    const marker = await markerRef.get();
    if (marker.exists) continue;

    const daysLeft = Math.ceil((userPackage.expiresAt.toMillis() - now.toMillis()) / (24 * 60 * 60 * 1000));
    const inboxEntry: InboxNotification = {
      id: "",
      sourceNotificationId: null,
      type: "packageExpiry",
      title: "Your package is expiring soon",
      titleAr: "باقتك على وشك الانتهاء",
      body: `Your package expires in ${daysLeft} day${daysLeft === 1 ? "" : "s"} — renew to keep booking.`,
      bodyAr: `تنتهي باقتك خلال ${daysLeft} يوم — جدد الآن لمواصلة الحجز.`,
      createdAt: Timestamp.now(),
      isRead: false,
      relatedBookingId: null,
    };
    const inboxRef = db.collection("users").doc(userPackage.userId).collection("inbox").doc();
    await inboxRef.set({ ...inboxEntry, id: inboxRef.id });
    await markerRef.set({ userPackageId: userPackage.id, sentAt: Timestamp.now() });
    sentCount++;
  }
  logger.info(`packageExpiryReminders: sent ${sentCount} reminder(s)`);
});
