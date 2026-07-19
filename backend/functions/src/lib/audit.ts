import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { Timestamp } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { db } from "./admin";
import type { AuditLogEntry } from "../models/types";

/**
 * Writes one auditLog entry. `actorUid` must come from a source the caller
 * already trusts — either a callable's verified `request.auth.uid`, or a
 * client-supplied `updatedBy` field that firestore.rules requires to equal
 * `request.auth.uid` on write (so a client can't forge someone else's uid).
 */
export async function logAudit(entry: Omit<AuditLogEntry, "id" | "createdAt">): Promise<void> {
  const ref = db.collection("auditLog").doc();
  await ref.set({ ...entry, id: ref.id, createdAt: Timestamp.now() });
}

/**
 * Firestore trigger factory for collections whose admin-dashboard writes
 * go straight from the client (create/update only — deletes are handled
 * separately by the `adminDelete` callable, since a delete carries no
 * document payload to read `updatedBy` from). Requires the client to have
 * written an `updatedBy` field; rules enforce it can't be forged.
 */
export function auditedCollectionTrigger(collectionPath: string, label: string, options: { alwaysExpectActor?: boolean } = {}) {
  const alwaysExpectActor = options.alwaysExpectActor ?? true;
  return onDocumentWritten(collectionPath, async (event) => {
    const before = event.data?.before?.exists ? event.data.before.data() : null;
    const after = event.data?.after?.exists ? event.data.after.data() : null;
    if (!after) return; // deletes are logged by adminDelete instead

    const docId = event.data?.after.id ?? "";
    const actorUid = (after as Record<string, unknown>).updatedBy as string | undefined;
    if (!actorUid) {
      // Expected for e.g. `users`, where most writes are customers editing
      // their own profile (never staff-initiated, so nothing to audit).
      if (alwaysExpectActor) {
        logger.warn(`auditedCollectionTrigger(${label}): write with no updatedBy field, skipping audit entry`, { docId });
      }
      return;
    }

    await logAudit({
      actorUid,
      action: before ? `${label}.update` : `${label}.create`,
      targetCollection: label,
      targetId: docId,
      before,
      after,
    });
  });
}
