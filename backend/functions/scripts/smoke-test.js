// Local verification script against the Firebase emulators (not deployed).
// Exercises the auth role-claim wiring and the booking capacity/waitlist
// Cloud Functions end-to-end. Run via `npm run smoke-test` from
// backend/functions with the emulators already running
// (`npx firebase-tools emulators:start` from backend/). Wired into CI via
// `firebase emulators:exec` — every assertion here must actually fail the
// process on violation (see `assert` below), not just log a warning,
// otherwise a broken invariant would report as a passing CI job.
const admin = require("firebase-admin");

admin.initializeApp({ projectId: "demo-swim-academy" });
const db = admin.firestore();
const auth = admin.auth();

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// Unlike console.assert, this actually throws — a failed assertion must
// fail the process (and the CI job), not just print a warning nobody reads.
function assert(condition, message) {
  if (!condition) throw new Error("FAIL: " + message);
}

function makeSession(overrides = {}) {
  return {
    classId: "c1",
    date: admin.firestore.Timestamp.now(),
    startMinutes: 600,
    endMinutes: 660,
    capacity: 1,
    bookedCount: 0,
    waitlistCount: 0,
    instructorId: "i1",
    branchId: "b1",
    ...overrides,
  };
}

function makeBooking(userId, participantName) {
  return {
    userId,
    sessionId: null, // set by caller
    participantId: userId,
    participantName,
    status: "confirmed", // client-optimistic; the function must be authoritative regardless
    createdAt: admin.firestore.Timestamp.now(),
    isRecurring: false,
    reviewed: false,
  };
}

async function main() {
  console.log("--- 1. Create a user, expect onUserCreate to set role claim + users/{uid} doc ---");
  const user = await auth.createUser({ email: `smoke-${Date.now()}@test.com`, password: "password123" });
  await sleep(1500); // let the onCreate trigger run
  const userRecord = await auth.getUser(user.uid);
  const userDoc = await db.collection("users").doc(user.uid).get();
  assert(userRecord.customClaims?.role === "customer", "custom claim not set to customer");
  assert(userDoc.exists && userDoc.data().role === "customer", "users/{uid} doc not created");
  console.log("OK: role claim =", userRecord.customClaims?.role, "| users doc role =", userDoc.data()?.role);

  console.log("\n--- 2. Session with capacity 1, book twice (sequential): second should waitlist ---");
  const sessionRef = db.collection("sessions").doc(`s-${Date.now()}`);
  await sessionRef.set({ id: sessionRef.id, ...makeSession() });

  const booking1Ref = db.collection("bookings").doc();
  await booking1Ref.set({ id: booking1Ref.id, ...makeBooking(user.uid, "Smoke Test"), sessionId: sessionRef.id });
  await sleep(1500);

  const booking2Ref = db.collection("bookings").doc();
  await booking2Ref.set({ id: booking2Ref.id, ...makeBooking(user.uid, "Smoke Test 2"), sessionId: sessionRef.id });
  await sleep(1500);

  let sessionSnap = await sessionRef.get();
  let b1 = (await booking1Ref.get()).data();
  let b2 = (await booking2Ref.get()).data();
  assert(b1.status === "confirmed", "booking1 should be confirmed, got " + b1.status);
  assert(b2.status === "waitlisted", "booking2 should be waitlisted, got " + b2.status);
  assert(sessionSnap.data().bookedCount === 1, "bookedCount should be 1, got " + sessionSnap.data().bookedCount);
  assert(sessionSnap.data().waitlistCount === 1, "waitlistCount should be 1, got " + sessionSnap.data().waitlistCount);
  console.log("OK: booking1 =", b1.status, "| booking2 =", b2.status, "| bookedCount =", sessionSnap.data().bookedCount, "| waitlistCount =", sessionSnap.data().waitlistCount);

  console.log("\n--- 3. Cancel booking1: booking2 should be promoted to confirmed ---");
  await booking1Ref.update({ status: "cancelled", cancelledAt: admin.firestore.Timestamp.now() });
  await sleep(1500);

  sessionSnap = await sessionRef.get();
  b2 = (await booking2Ref.get()).data();
  assert(b2.status === "confirmed", "booking2 should be promoted to confirmed, got " + b2.status);
  assert(sessionSnap.data().waitlistCount === 0, "waitlistCount should be back to 0, got " + sessionSnap.data().waitlistCount);
  assert(sessionSnap.data().bookedCount === 1, "bookedCount should still be 1 (one seat, now filled by the promoted booking), got " + sessionSnap.data().bookedCount);
  console.log("OK: booking2 (after promotion) =", b2.status, "| bookedCount =", sessionSnap.data().bookedCount, "| waitlistCount =", sessionSnap.data().waitlistCount);

  const inbox = await db.collection("users").doc(user.uid).collection("inbox").get();
  assert(inbox.size >= 3, "expected at least 3 inbox notifications, got " + inbox.size);
  console.log("OK: inbox has", inbox.size, "notifications");

  console.log("\n--- 4. Session with capacity 1, book twice CONCURRENTLY: transaction must still serialize ---");
  // The sequential case above (with a 1.5s sleep between writes) can't tell
  // a correctly-serialized transaction apart from one that's merely never
  // been exercised concurrently. Firing both creates via Promise.all is the
  // actual claim under test: "concurrent bookings can't over-fill a
  // session."
  const concurrentSessionRef = db.collection("sessions").doc(`s-concurrent-${Date.now()}`);
  await concurrentSessionRef.set({ id: concurrentSessionRef.id, ...makeSession() });

  const concurrentBooking1Ref = db.collection("bookings").doc();
  const concurrentBooking2Ref = db.collection("bookings").doc();
  await Promise.all([
    concurrentBooking1Ref.set({
      id: concurrentBooking1Ref.id,
      ...makeBooking(user.uid, "Concurrent A"),
      sessionId: concurrentSessionRef.id,
    }),
    concurrentBooking2Ref.set({
      id: concurrentBooking2Ref.id,
      ...makeBooking(user.uid, "Concurrent B"),
      sessionId: concurrentSessionRef.id,
    }),
  ]);
  await sleep(2000); // both onBookingCreate invocations need time to settle

  const concurrentSessionSnap = await concurrentSessionRef.get();
  const cb1 = (await concurrentBooking1Ref.get()).data();
  const cb2 = (await concurrentBooking2Ref.get()).data();
  const statuses = [cb1.status, cb2.status].sort();
  assert(
    statuses[0] === "confirmed" && statuses[1] === "waitlisted",
    "concurrent bookings should resolve to exactly one confirmed + one waitlisted, got " + JSON.stringify(statuses)
  );
  assert(
    concurrentSessionSnap.data().bookedCount === 1,
    "concurrent bookedCount should be exactly 1 (no over-fill), got " + concurrentSessionSnap.data().bookedCount
  );
  assert(
    concurrentSessionSnap.data().waitlistCount === 1,
    "concurrent waitlistCount should be exactly 1, got " + concurrentSessionSnap.data().waitlistCount
  );
  console.log(
    "OK: concurrent bookings resolved to",
    statuses.join(" + "),
    "| bookedCount =",
    concurrentSessionSnap.data().bookedCount,
    "| waitlistCount =",
    concurrentSessionSnap.data().waitlistCount
  );

  console.log("\n--- 5. assignStaffRole: unauthenticated caller must be rejected ---");
  const functionsUrl = "http://127.0.0.1:5001/demo-swim-academy/us-central1/assignStaffRole";
  const res = await fetch(functionsUrl, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ data: { targetUid: user.uid, role: "admin" } }),
  });
  const body = await res.json();
  assert(res.status !== 200 || body.error, "unauthenticated assignStaffRole call should be rejected");
  console.log("OK: unauthenticated call rejected with", res.status, JSON.stringify(body).slice(0, 200));

  console.log("\nAll smoke test assertions passed.");
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error("SMOKE TEST FAILED:", err);
    process.exit(1);
  });
