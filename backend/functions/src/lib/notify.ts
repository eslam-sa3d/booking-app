import { getMessaging } from "firebase-admin/messaging";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { db } from "./admin";
import type { AppUser, InboxNotification, NotificationType } from "../models/types";

type PreferenceCategory = "reminders" | "promotions" | "announcements";

// Transactional types (booking confirmed/cancelled/waitlisted, waitlist
// promotion) are never gated by preference — they're direct consequences
// of the user's own action. Only the categories the spec names as
// opt-in/opt-out are checked here.
const CATEGORY_BY_TYPE: Partial<Record<NotificationType, PreferenceCategory>> = {
  reminder: "reminders",
  packageExpiry: "reminders",
  promotion: "promotions",
  general: "announcements",
};

export interface NotifyPayload {
  type: NotificationType;
  title: string;
  titleAr: string;
  body: string;
  bodyAr: string;
  sourceNotificationId?: string | null;
  relatedBookingId?: string | null;
}

async function filterByPreference(uids: string[], type: NotificationType): Promise<string[]> {
  const category = CATEGORY_BY_TYPE[type];
  if (!category || uids.length === 0) return uids;
  const docs = await db.getAll(...uids.map((uid) => db.collection("users").doc(uid)));
  return docs
    .filter((d) => {
      const prefs = (d.data() as AppUser | undefined)?.notificationPreferences;
      return prefs?.[category] !== false; // default: opted in
    })
    .map((d) => d.id);
}

/**
 * Writes an in-app inbox copy and best-effort sends an FCM push for each
 * uid, respecting notification category preferences. The inbox write is
 * the durable record — a missing/invalid FCM token never blocks it.
 */
export async function notifyUsers(uids: string[], payload: NotifyPayload): Promise<void> {
  const targets = await filterByPreference([...new Set(uids)], payload.type);
  if (targets.length === 0) return;

  const batchSize = 400; // stay under Firestore's 500-write batch limit
  for (let i = 0; i < targets.length; i += batchSize) {
    const batch = db.batch();
    for (const uid of targets.slice(i, i + batchSize)) {
      const ref = db.collection("users").doc(uid).collection("inbox").doc();
      const entry: InboxNotification = {
        id: ref.id,
        sourceNotificationId: payload.sourceNotificationId ?? null,
        type: payload.type,
        title: payload.title,
        titleAr: payload.titleAr,
        body: payload.body,
        bodyAr: payload.bodyAr,
        createdAt: Timestamp.now(),
        isRead: false,
        relatedBookingId: payload.relatedBookingId ?? null,
      };
      batch.set(ref, entry);
    }
    await batch.commit();
  }

  const userDocs = await db.getAll(...targets.map((uid) => db.collection("users").doc(uid)));
  const tokenOwners = userDocs.flatMap((d) =>
    ((d.data()?.fcmTokens as string[] | undefined) ?? []).map((token) => ({ uid: d.id, token }))
  );
  if (tokenOwners.length === 0) return;
  const tokens = tokenOwners.map((t) => t.token);

  try {
    const response = await getMessaging().sendEachForMulticast({
      tokens,
      notification: { title: payload.title, body: payload.body },
      data: {
        type: payload.type,
        ...(payload.sourceNotificationId ? { notificationId: payload.sourceNotificationId } : {}),
        ...(payload.relatedBookingId ? { bookingId: payload.relatedBookingId } : {}),
      },
    });
    logger.info(`notifyUsers: sent to ${response.successCount}/${tokens.length} tokens`, { type: payload.type });
    await pruneStaleTokens(tokenOwners, response.responses);
  } catch (err) {
    logger.error("notifyUsers: FCM send failed", err);
  }
}

const STALE_TOKEN_CODES = new Set([
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
]);

// FCM never re-validates a token once it's stale — every future send keeps
// paying for and undercounting delivery against it — so drop it from the
// owning user's fcmTokens the moment the API confirms it's dead.
async function pruneStaleTokens(
  tokenOwners: { uid: string; token: string }[],
  responses: { success: boolean; error?: { code: string } }[]
): Promise<void> {
  const staleByUid = new Map<string, string[]>();
  responses.forEach((r, i) => {
    if (r.success || !r.error || !STALE_TOKEN_CODES.has(r.error.code)) return;
    const { uid, token } = tokenOwners[i];
    staleByUid.set(uid, [...(staleByUid.get(uid) ?? []), token]);
  });
  if (staleByUid.size === 0) return;

  const batch = db.batch();
  let staleCount = 0;
  for (const [uid, staleTokens] of staleByUid) {
    batch.update(db.collection("users").doc(uid), {
      fcmTokens: FieldValue.arrayRemove(...staleTokens),
    });
    staleCount += staleTokens.length;
  }
  await batch.commit();
  logger.info(`notifyUsers: pruned ${staleCount} stale tokens across ${staleByUid.size} users`);
}
