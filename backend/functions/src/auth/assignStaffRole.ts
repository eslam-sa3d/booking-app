import { onCall, HttpsError } from "firebase-functions/v2/https";
import { auth, db } from "../lib/admin";
import { logAudit } from "../lib/audit";
import type { Role } from "../models/types";

interface AssignStaffRoleRequest {
  targetUid: string;
  role: Role;
}

/**
 * Callable used by the admin dashboard's "Staff Accounts" screen to
 * promote/demote a user between customer/staff/admin. Only an existing
 * admin (checked via the caller's own custom claim, not a client-supplied
 * flag) may call this — this is the *only* legitimate way a role changes
 * after account creation.
 */
export const assignStaffRole = onCall<AssignStaffRoleRequest>(async (request) => {
  const callerRole = request.auth?.token?.role;
  if (!request.auth || callerRole !== "admin") {
    throw new HttpsError("permission-denied", "Only an admin can assign roles.");
  }

  const { targetUid, role } = request.data;
  if (!targetUid || !["customer", "staff", "admin"].includes(role)) {
    throw new HttpsError("invalid-argument", "targetUid and a valid role are required.");
  }

  const beforeSnapshot = await db.collection("users").doc(targetUid).get();
  const before = beforeSnapshot.data() ?? null;

  await auth.setCustomUserClaims(targetUid, { role });
  await db.collection("users").doc(targetUid).set({ role }, { merge: true });

  await logAudit({
    actorUid: request.auth.uid,
    action: "assignStaffRole",
    targetCollection: "users",
    targetId: targetUid,
    before,
    after: { role },
  });

  return { success: true };
});
