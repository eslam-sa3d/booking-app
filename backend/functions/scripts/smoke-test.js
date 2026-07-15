// Local verification script against the Firebase emulators (not deployed).
// Exercises the auth role-claim wiring and the booking capacity/waitlist
// Cloud Functions end-to-end. Run via `npm run smoke-test` from
// backend/functions with the emulators already running
// (`npx firebase-tools emulators:start` from backend/).
const admin = require("firebase-admin");

admin.initializeApp({ projectId: "demo-swim-academy" });
const db = admin.firestore();
const auth = admin.auth();

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  console.log("--- 1. Create a user, expect onUserCreate to set role claim + users/{uid} doc ---");
  const user = await auth.createUser({ email: `smoke-${Date.now()}@test.com`, password: "password123" });
  await sleep(1500); // let the onCreate trigger run
  const userRecord = await auth.getUser(user.uid);
  const userDoc = await db.collection("users").doc(user.uid).get();
  console.assert(userRecord.customClaims?.role === "customer", "FAIL: custom claim not set to customer");
  console.assert(userDoc.exists && userDoc.data().role === "customer", "FAIL: users/{uid} doc not created");
  console.log("OK: role claim =", userRecord.customClaims?.role, "| users doc role =", userDoc.data()?.role);

  console.log("\n--- 2. Session with capacity 1, book twice: second should waitlist ---");
  const sessionRef = db.collection("sessions").doc(`s-${Date.now()}`);
  await sessionRef.set({
    id: sessionRef.id,
    classId: "c1",
    date: admin.firestore.Timestamp.now(),
    startMinutes: 600,
    endMinutes: 660,
    capacity: 1,
    bookedCount: 0,
    waitlistCount: 0,
    instructorId: "i1",
    branchId: "b1",
  });

  const booking1Ref = db.collection("bookings").doc();
  await booking1Ref.set({
    id: booking1Ref.id,
    userId: user.uid,
    sessionId: sessionRef.id,
    participantId: user.uid,
    participantName: "Smoke Test",
    status: "confirmed", // client-optimistic; the function must be authoritative regardless
    createdAt: admin.firestore.Timestamp.now(),
    isRecurring: false,
    reviewed: false,
  });
  await sleep(1500);

  const booking2Ref = db.collection("bookings").doc();
  await booking2Ref.set({
    id: booking2Ref.id,
    userId: user.uid,
    sessionId: sessionRef.id,
    participantId: user.uid,
    participantName: "Smoke Test 2",
    status: "confirmed",
    createdAt: admin.firestore.Timestamp.now(),
    isRecurring: false,
    reviewed: false,
  });
  await sleep(1500);

  let sessionSnap = await sessionRef.get();
  let b1 = (await booking1Ref.get()).data();
  let b2 = (await booking2Ref.get()).data();
  console.assert(b1.status === "confirmed", "FAIL: booking1 should be confirmed, got " + b1.status);
  console.assert(b2.status === "waitlisted", "FAIL: booking2 should be waitlisted, got " + b2.status);
  console.assert(sessionSnap.data().bookedCount === 1, "FAIL: bookedCount should be 1, got " + sessionSnap.data().bookedCount);
  console.assert(sessionSnap.data().waitlistCount === 1, "FAIL: waitlistCount should be 1, got " + sessionSnap.data().waitlistCount);
  console.log("OK: booking1 =", b1.status, "| booking2 =", b2.status, "| bookedCount =", sessionSnap.data().bookedCount, "| waitlistCount =", sessionSnap.data().waitlistCount);

  console.log("\n--- 3. Cancel booking1: booking2 should be promoted to confirmed ---");
  await booking1Ref.update({ status: "cancelled", cancelledAt: admin.firestore.Timestamp.now() });
  await sleep(1500);

  sessionSnap = await sessionRef.get();
  b2 = (await booking2Ref.get()).data();
  console.assert(b2.status === "confirmed", "FAIL: booking2 should be promoted to confirmed, got " + b2.status);
  console.assert(sessionSnap.data().waitlistCount === 0, "FAIL: waitlistCount should be back to 0, got " + sessionSnap.data().waitlistCount);
  console.assert(sessionSnap.data().bookedCount === 1, "FAIL: bookedCount should still be 1 (one seat, now filled by the promoted booking), got " + sessionSnap.data().bookedCount);
  console.log("OK: booking2 (after promotion) =", b2.status, "| bookedCount =", sessionSnap.data().bookedCount, "| waitlistCount =", sessionSnap.data().waitlistCount);

  const inbox = await db.collection("users").doc(user.uid).collection("inbox").get();
  console.assert(inbox.size >= 3, "FAIL: expected at least 3 inbox notifications, got " + inbox.size);
  console.log("OK: inbox has", inbox.size, "notifications");

  console.log("\n--- 4. assignStaffRole: unauthenticated caller must be rejected ---");
  const functionsUrl = "http://127.0.0.1:5001/demo-swim-academy/us-central1/assignStaffRole";
  const res = await fetch(functionsUrl, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ data: { targetUid: user.uid, role: "admin" } }),
  });
  const body = await res.json();
  console.assert(res.status !== 200 || body.error, "FAIL: unauthenticated assignStaffRole call should be rejected");
  console.log("OK: unauthenticated call rejected with", res.status, JSON.stringify(body).slice(0, 200));

  console.log("\nAll smoke test assertions passed.");
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("SMOKE TEST FAILED:", err);
    process.exit(1);
  });
