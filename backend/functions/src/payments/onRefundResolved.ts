import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { notifyUsers } from "../lib/notify";
import type { Transaction } from "../models/types";

/**
 * Notifies the customer when an admin approves/denies their refund
 * request. Fires only on the actual transition into 'approved'/'denied' —
 * `refundRequestStatus` is a direct consequence of the customer's own
 * refund request, so (like a booking confirmation) it's never gated by
 * notification preferences.
 */
export const onRefundResolved = onDocumentUpdated("transactions/{transactionId}", async (event) => {
  const before = event.data?.before.data() as Transaction | undefined;
  const after = event.data?.after.data() as Transaction | undefined;
  if (!before || !after) return;
  if (before.refundRequestStatus === after.refundRequestStatus) return;
  if (after.refundRequestStatus !== "approved" && after.refundRequestStatus !== "denied") return;

  const approved = after.refundRequestStatus === "approved";
  try {
    await notifyUsers([after.userId], {
      type: "refundResolved",
      title: approved ? "Refund approved" : "Refund request denied",
      titleAr: approved ? "تمت الموافقة على الاسترداد" : "تم رفض طلب الاسترداد",
      body: approved
        ? `Your refund request for ${after.description} has been approved.`
        : `Your refund request for ${after.description} was denied.`,
      bodyAr: approved
        ? `تمت الموافقة على طلب استرداد ${after.descriptionAr}.`
        : `تم رفض طلب استرداد ${after.descriptionAr}.`,
      relatedBookingId: after.relatedBookingId ?? null,
    });
  } catch (err) {
    logger.error(`onRefundResolved: notifyUsers failed for transaction ${after.id}`, err);
  }
});
