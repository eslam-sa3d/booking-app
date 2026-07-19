import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { db } from "../lib/admin";
import { notifyUsers } from "../lib/notify";
import type { Booking, SwimSession, UserPackage } from "../models/types";

/**
 * Fires on every booking update; only acts on the transition into
 * 'cancelled'. Frees the session capacity and, if a confirmed spot opened
 * up, promotes the earliest waitlisted booking for that session — the
 * waitlist half of the capacity/waitlist contract onBookingCreate sets up.
 * Also refunds a session credit to the package onBookingCreate drew it
 * from, if any.
 */
export const onBookingCancel = onDocumentUpdated("bookings/{bookingId}", async (event) => {
  const before = event.data?.before.data() as Booking | undefined;
  const after = event.data?.after.data() as Booking | undefined;
  if (!before || !after) return;
  if (before.status === "cancelled" || after.status !== "cancelled") return;

  const sessionRef = db.collection("sessions").doc(after.sessionId);

  let promoted: Booking | undefined;
  try {
    promoted = await db.runTransaction(async (tx) => {
      const sessionSnap = await tx.get(sessionRef);
      const packageRef = before.userPackageId
        ? db.collection("users").doc(before.userId).collection("packages").doc(before.userPackageId)
        : null;
      const packageSnap = packageRef ? await tx.get(packageRef) : null;

      // All reads must happen before any writes in a Firestore transaction.
      let waitlistDocs: FirebaseFirestore.QueryDocumentSnapshot[] = [];
      if (before.status === "confirmed") {
        const waitlistQuery = await tx.get(
          db
            .collection("bookings")
            .where("sessionId", "==", after.sessionId)
            .where("status", "==", "waitlisted")
            .orderBy("createdAt", "asc")
            .limit(1)
        );
        waitlistDocs = waitlistQuery.docs;
      }

      if (sessionSnap.exists) {
        const session = sessionSnap.data() as SwimSession;
        if (before.status === "confirmed") {
          if (waitlistDocs.length > 0) {
            // One seat freed, immediately re-filled by the promoted booking —
            // bookedCount is net unchanged, only the waitlist shrinks.
            tx.update(waitlistDocs[0].ref, { status: "confirmed" });
            tx.update(sessionRef, { waitlistCount: Math.max(0, (session.waitlistCount ?? 0) - 1) });
          } else {
            tx.update(sessionRef, { bookedCount: Math.max(0, (session.bookedCount ?? 0) - 1) });
          }
        } else if (before.status === "waitlisted") {
          tx.update(sessionRef, { waitlistCount: Math.max(0, (session.waitlistCount ?? 0) - 1) });
        }
      }

      if (packageRef && packageSnap?.exists) {
        const pkg = packageSnap.data() as UserPackage;
        tx.update(packageRef, { sessionsRemaining: (pkg.sessionsRemaining ?? 0) + 1 });
      }

      return waitlistDocs[0]?.data() as Booking | undefined;
    });
  } catch (err) {
    logger.error(`onBookingCancel: transaction failed for booking ${after.id}`, err);
    return;
  }

  try {
    await notifyUsers([after.userId], {
      type: "cancellation",
      title: "Booking cancelled",
      titleAr: "تم إلغاء الحجز",
      body: `Your booking for ${after.participantName} has been cancelled.`,
      bodyAr: `تم إلغاء حجزك لـ ${after.participantName}.`,
      relatedBookingId: after.id,
    });

    if (promoted) {
      await notifyUsers([promoted.userId], {
        type: "waitlistPromoted",
        title: "You're off the waitlist!",
        titleAr: "تم نقلك من قائمة الانتظار!",
        body: `A spot opened up for ${promoted.participantName} — your booking is now confirmed.`,
        bodyAr: `توفر مكان لـ ${promoted.participantName} — تم تأكيد حجزك الآن.`,
        relatedBookingId: promoted.id,
      });
    }
  } catch (err) {
    logger.error(`onBookingCancel: notifyUsers failed for booking ${after.id} (cancellation itself succeeded)`, err);
  }
});
