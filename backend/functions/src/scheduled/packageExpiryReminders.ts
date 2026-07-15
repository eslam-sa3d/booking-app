import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

/**
 * TODO(next phase): runs daily; will query the `packages` collection
 * group across all users for `status == 'active'` and `expiresAt` within
 * the next N days, then create a `notifications`/inbox entry (reusing the
 * dispatch pipeline in notifications/dispatch.ts) reminding each owner
 * their package is expiring soon.
 */
export const packageExpiryReminders = onSchedule("every day 09:00", async () => {
  logger.warn("packageExpiryReminders triggered but not yet implemented");
});
