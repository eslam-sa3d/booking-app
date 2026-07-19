import { onCall, HttpsError } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { db } from "../lib/admin";
import type { SwimPackage, UserPackage, Transaction, PaymentMethod, PaymentStatus } from "../models/types";

interface PurchasePackageRequest {
  packageId: string;
  method: PaymentMethod;
  // 'succeeded' grants the package; 'failed' and 'pending' (the
  // admin-configured external payment-link flow, reconciled manually) only
  // record the transaction attempt.
  status: Extract<PaymentStatus, "succeeded" | "failed" | "pending">;
  failureReason?: string | null;
}

/**
 * Records a package-purchase transaction and, if the charge succeeded,
 * grants the package — both server-side. firestore.rules blocks direct
 * client writes to `users/{uid}/packages` (staff/admin-only) and
 * `transactions` (create/update requires isAdmin()), so this callable is
 * the only path a customer's own purchase can take. A raw Firestore write
 * can no longer self-grant free session credits.
 *
 * `status` reflects the mobile app's `MockPaymentService` result (real
 * gateway integration is deferred — see payments/webhook.ts). This callable
 * doesn't yet independently re-verify a charge happened, since there's no
 * real gateway to verify against; it only closes the "arbitrary client
 * Firestore write" vector and centralizes the grant logic in one place so
 * real verification can be added here once a gateway is chosen.
 */
export const purchasePackage = onCall<PurchasePackageRequest>(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }
  const userId = request.auth.uid;
  const { packageId, method, status, failureReason } = request.data;
  if (!packageId || !method || !["succeeded", "failed", "pending"].includes(status)) {
    throw new HttpsError("invalid-argument", "packageId, method, and a valid status are required.");
  }

  const packageSnap = await db.collection("packages").doc(packageId).get();
  if (!packageSnap.exists) {
    throw new HttpsError("not-found", `packages/${packageId} does not exist.`);
  }
  const pkg = packageSnap.data() as SwimPackage;

  const now = Timestamp.now();
  const transactionRef = db.collection("transactions").doc();
  const transaction: Transaction = {
    id: transactionRef.id,
    userId,
    amount: pkg.price,
    currency: pkg.currency,
    method,
    status,
    createdAt: now,
    description: `${pkg.name} purchase`,
    descriptionAr: `شراء ${pkg.nameAr}`,
    relatedPackageId: packageId,
    relatedBookingId: null,
    gatewayReference: null,
    receiptNumber: null,
  };

  if (status !== "succeeded") {
    await transactionRef.set(transaction);
    return { transaction: serializeTransaction(transaction), userPackage: null, failureReason: failureReason ?? null };
  }

  const expiresAt = Timestamp.fromMillis(now.toMillis() + pkg.validityDays * 24 * 60 * 60 * 1000);
  const userPackageRef = db.collection("users").doc(userId).collection("packages").doc();
  const userPackage: UserPackage = {
    id: userPackageRef.id,
    userId,
    packageId,
    purchasedAt: now,
    expiresAt,
    sessionsRemaining: pkg.sessionCount ?? null,
    status: "active",
  };

  const batch = db.batch();
  batch.set(transactionRef, transaction);
  batch.set(userPackageRef, userPackage);
  await batch.commit();

  return { transaction: serializeTransaction(transaction), userPackage: serializeUserPackage(userPackage), failureReason: null };
});

// The callable wire protocol doesn't round-trip Admin SDK Timestamp objects
// back into client Timestamps, so dates are serialized as ISO strings —
// shared/lib/src/firestore_codec.dart's parseTimestamp already handles
// String inputs alongside real Firestore Timestamps.
function serializeTransaction(t: Transaction) {
  return { ...t, createdAt: t.createdAt.toDate().toISOString() };
}

function serializeUserPackage(p: UserPackage) {
  return { ...p, purchasedAt: p.purchasedAt.toDate().toISOString(), expiresAt: p.expiresAt.toDate().toISOString() };
}
