import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { Timestamp } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { db } from "../lib/admin";
import { notifyUsers } from "../lib/notify";
import type { Booking, SwimSession, UserPackage } from "../models/types";

/**
 * The client creates the booking document optimistically, but this
 * function is the sole source of truth for its final `status` and for the
 * session's `bookedCount`/`waitlistCount` — both mutated together inside
 * one transaction so a burst of simultaneous bookings can never
 * over-fill a session's capacity. A confirmed (not waitlisted) booking
 * also draws one session credit from the user's earliest-expiring active
 * sessionPack package with sessions remaining, if they have one.
 */
export const onBookingCreate = onDocumentCreated("bookings/{bookingId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;

  const booking = snapshot.data() as Booking;
  const bookingRef = snapshot.ref;
  const sessionRef = db.collection("sessions").doc(booking.sessionId);
  const userPackagesRef = db.collection("users").doc(booking.userId).collection("packages");

  let finalStatus: "confirmed" | "waitlisted";
  let consumedPackageId: string | null = null;
  try {
    finalStatus = await db.runTransaction(async (tx) => {
      const sessionSnap = await tx.get(sessionRef);
      if (!sessionSnap.exists) {
        throw new Error(`Session ${booking.sessionId} not found for booking ${bookingRef.id}`);
      }
      const session = sessionSnap.data() as SwimSession;
      const bookedCount = session.bookedCount ?? 0;
      const isFull = bookedCount >= session.capacity;

      if (isFull) {
        tx.update(sessionRef, { waitlistCount: (session.waitlistCount ?? 0) + 1 });
        tx.update(bookingRef, { status: "waitlisted" });
        return "waitlisted" as const;
      }

      // All reads must happen before any writes in a Firestore transaction.
      const packageQuery = await tx.get(
        userPackagesRef.where("status", "==", "active").where("sessionsRemaining", ">", 0).limit(10)
      );
      const now = Timestamp.now();
      const candidates = packageQuery.docs
        .map((d) => d.data() as UserPackage)
        .filter((p) => p.expiresAt.toMillis() > now.toMillis())
        .sort((a, b) => a.expiresAt.toMillis() - b.expiresAt.toMillis());
      const chosenPackage = candidates[0];

      tx.update(sessionRef, { bookedCount: bookedCount + 1 });
      const bookingUpdate: Partial<Booking> = { status: "confirmed" };
      if (chosenPackage) {
        bookingUpdate.userPackageId = chosenPackage.id;
        tx.update(userPackagesRef.doc(chosenPackage.id), {
          sessionsRemaining: (chosenPackage.sessionsRemaining ?? 1) - 1,
        });
        consumedPackageId = chosenPackage.id;
      }
      tx.update(bookingRef, bookingUpdate);
      return "confirmed" as const;
    });
  } catch (err) {
    // The client's optimistic 'pending' booking is left uncorrected — it
    // needs manual reconciliation (or the client's own confirmation-wait
    // will eventually time out and surface an error to the user). Logged
    // distinctly from a notify failure below, which is safe to swallow
    // since the business-critical write already succeeded by that point.
    logger.error(`onBookingCreate: transaction failed for booking ${bookingRef.id}`, err);
    return;
  }

  logger.info(`onBookingCreate: booking ${bookingRef.id} -> ${finalStatus}`, { consumedPackageId });

  const isWaitlisted = finalStatus === "waitlisted";
  try {
    await notifyUsers([booking.userId], {
      type: isWaitlisted ? "waitlisted" : "bookingConfirmed",
      title: isWaitlisted ? "Added to waitlist" : "Booking confirmed",
      titleAr: isWaitlisted ? "تمت الإضافة لقائمة الانتظار" : "تم تأكيد الحجز",
      body: isWaitlisted
        ? `You are on the waitlist for ${booking.participantName}.`
        : `Your booking for ${booking.participantName} is confirmed.`,
      bodyAr: isWaitlisted
        ? `أنت الآن في قائمة الانتظار لـ ${booking.participantName}.`
        : `تم تأكيد حجزك لـ ${booking.participantName}.`,
      relatedBookingId: bookingRef.id,
    });
  } catch (err) {
    logger.error(`onBookingCreate: notifyUsers failed for booking ${bookingRef.id} (booking itself succeeded)`, err);
  }
});
