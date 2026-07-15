import { onCall, HttpsError } from "firebase-functions/v2/https";
import { Timestamp } from "firebase-admin/firestore";
import { auth, db } from "../lib/admin";
import type { Role, AuditLogEntry } from "../models/types";

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

  const entry: AuditLogEntry = {
    id: "",
    actorUid: request.auth.uid,
    action: "assignStaffRole",
    targetCollection: "users",
    targetId: targetUid,
    before,
    after: { role },
    createdAt: Timestamp.now(),
  };
  await db.collection("auditLog").add(entry);

  return { success: true };
});
