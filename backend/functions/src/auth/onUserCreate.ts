import * as functionsV1 from "firebase-functions/v1";
import { Timestamp } from "firebase-admin/firestore";
import { auth, db } from "../lib/admin";
import type { AppUser } from "../models/types";

/**
 * Fires when a new Firebase Auth account is created (email/password,
 * Google, or Apple sign-in). Every new account starts as a 'customer' —
 * promotion to 'staff'/'admin' only happens via the assignStaffRole
 * callable, never here.
 *
 * The custom claim is the security-authoritative role (checked by every
 * firestore.rules `role()` call); the mirrored `users/{uid}.role` field
 * exists purely so the client and admin dashboard can read/query it
 * without needing to decode the ID token.
 */
export const onUserCreate = functionsV1.auth.user().onCreate(async (user) => {
  await auth.setCustomUserClaims(user.uid, { role: "customer" });

  const profile: AppUser = {
    id: user.uid,
    name: user.displayName ?? "",
    email: user.email ?? "",
    phone: user.phoneNumber ?? "",
    photoUrl: user.photoURL ?? null,
    preferredLanguage: "en",
    role: "customer",
    createdAt: Timestamp.now(),
  };

  await db.collection("users").doc(user.uid).set(profile, { merge: true });
});
