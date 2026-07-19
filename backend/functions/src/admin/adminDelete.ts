import { onCall, HttpsError } from "firebase-functions/v2/https";
import { db } from "../lib/admin";
import { logAudit } from "../lib/audit";

// Collections the admin dashboard may delete from, and the minimum role
// required — mirrors the write-permission matrix in firestore.rules.
const DELETABLE: Record<string, "staff" | "admin"> = {
  classes: "staff",
  sessions: "staff",
  banners: "staff",
  packages: "staff",
  instructors: "staff",
  categories: "staff",
  blockedDates: "staff",
  // Matches firestore.rules: `allow delete: if isAdmin();` on paymentMethods.
  paymentMethods: "admin",
};

interface AdminDeleteRequest {
  collection: string;
  docId: string;
}

/**
 * A Firestore `delete` carries no document payload, so there's nothing for
 * the audited-collection triggers (lib/audit.ts) to read an actor off of —
 * unlike create/update, which go straight from the client with a
 * rules-enforced `updatedBy` field. Routing deletes through this callable
 * instead gives every delete a verified actor (the callable's own auth
 * context) and a captured "before" snapshot, logged directly here.
 */
export const adminDelete = onCall<AdminDeleteRequest>(async (request) => {
  const role = request.auth?.token?.role as string | undefined;
  if (!request.auth || (role !== "staff" && role !== "admin")) {
    throw new HttpsError("permission-denied", "Only staff or admin may delete.");
  }

  const { collection, docId } = request.data;
  const required = DELETABLE[collection];
  if (!required || !docId) {
    throw new HttpsError("invalid-argument", "Unknown or missing collection/docId.");
  }
  if (required === "admin" && role !== "admin") {
    throw new HttpsError("permission-denied", `Deleting from ${collection} requires admin.`);
  }

  const ref = db.collection(collection).doc(docId);
  const before = (await ref.get()).data() ?? null;
  if (!before) {
    throw new HttpsError("not-found", `${collection}/${docId} does not exist.`);
  }

  await ref.delete();
  await logAudit({
    actorUid: request.auth.uid,
    action: `${collection}.delete`,
    targetCollection: collection,
    targetId: docId,
    before,
    after: null,
  });

  return { success: true };
});
