import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { db } from "../lib/admin";
import { notifyUsers } from "../lib/notify";
import type { Booking, SwimSession } from "../models/types";

/**
 * The client creates the booking document optimistically, but this
 * function is the sole source of truth for its final `status` and for the
 * session's `bookedCount`/`waitlistCount` — both mutated together inside
 * one transaction so a burst of simultaneous bookings can never
 * over-fill a session's capacity.
 */
export const onBookingCreate = onDocumentCreated("bookings/{bookingId}", async (event) => {
  const snapshot = event.data;
  if (!snapshot) return;

  const booking = snapshot.data() as Booking;
  const bookingRef = snapshot.ref;
  const sessionRef = db.collection("sessions").doc(booking.sessionId);

  const finalStatus = await db.runTransaction(async (tx) => {
    const sessionSnap = await tx.get(sessionRef);
    if (!sessionSnap.exists) {
      throw new Error(`Session ${booking.sessionId} not found for booking ${bookingRef.id}`);
    }
    const session = sessionSnap.data() as SwimSession;
    const isFull = session.bookedCount >= session.capacity;

    if (isFull) {
      tx.update(sessionRef, { waitlistCount: (session.waitlistCount ?? 0) + 1 });
      tx.update(bookingRef, { status: "waitlisted" });
      return "waitlisted" as const;
    }

    tx.update(sessionRef, { bookedCount: session.bookedCount + 1 });
    tx.update(bookingRef, { status: "confirmed" });
    return "confirmed" as const;
  });

  const isWaitlisted = finalStatus === "waitlisted";
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
});
