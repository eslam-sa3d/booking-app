import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import { Timestamp } from "firebase-admin/firestore";
import { db } from "../lib/admin";
import { notifyUsers } from "../lib/notify";
import type { SwimSession, Booking } from "../models/types";

const REMINDER_LEAD_MINUTES = 120;
const RUN_WINDOW_MINUTES = 15; // matches the schedule interval below

function sessionStartMillis(session: SwimSession): number {
  const d = session.date.toDate();
  const midnightUtc = Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate());
  return midnightUtc + session.startMinutes * 60 * 1000;
}

/**
 * Runs every 15 minutes. Reminds every confirmed booking's user 2 hours
 * before their session starts — a `sentSessionReminders/{bookingId}`
 * marker (mirroring packageExpiryReminders' pattern) keeps overlapping
 * runs from double-sending.
 */
export const sessionReminders = onSchedule("every 15 minutes", async () => {
  const now = Date.now();
  const windowStart = now + REMINDER_LEAD_MINUTES * 60 * 1000;
  const windowEnd = windowStart + RUN_WINDOW_MINUTES * 60 * 1000;

  // Bound the query to a ~3-day span (session.date is midnight-anchored,
  // startMinutes pushes it later in the day) rather than scanning every
  // future session; the exact 2-hour window is filtered in memory below.
  const rangeStart = Timestamp.fromMillis(now - 24 * 60 * 60 * 1000);
  const rangeEnd = Timestamp.fromMillis(now + 2 * 24 * 60 * 60 * 1000);
  const sessionsSnap = await db.collection("sessions").where("date", ">=", rangeStart).where("date", "<=", rangeEnd).get();

  const dueSessions = sessionsSnap.docs.map((d) => d.data() as SwimSession).filter((s) => {
    const start = sessionStartMillis(s);
    return start >= windowStart && start < windowEnd;
  });
  if (dueSessions.length === 0) return;

  let sentCount = 0;
  for (const session of dueSessions) {
    const bookingsSnap = await db
      .collection("bookings")
      .where("sessionId", "==", session.id)
      .where("status", "==", "confirmed")
      .get();

    for (const bookingDoc of bookingsSnap.docs) {
      const booking = bookingDoc.data() as Booking;
      const markerRef = db.collection("sentSessionReminders").doc(booking.id);
      if ((await markerRef.get()).exists) continue;

      await notifyUsers([booking.userId], {
        type: "reminder",
        title: "Upcoming session in 2 hours",
        titleAr: "حصتك القادمة بعد ساعتين",
        body: `${booking.participantName}'s session starts soon — see you at the pool!`,
        bodyAr: `حصة ${booking.participantName} تبدأ قريباً — نراكم في المسبح!`,
        relatedBookingId: booking.id,
      });
      await markerRef.set({ bookingId: booking.id, sentAt: Timestamp.now() });
      sentCount++;
    }
  }
  logger.info(`sessionReminders: sent ${sentCount} reminder(s)`);
});
