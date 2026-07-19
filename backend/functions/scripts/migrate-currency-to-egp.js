// One-off migration: updates every existing Firestore document whose
// currency field is still "SAR" to "EGP", following the SAR -> EGP code
// change. Only touches documents that actually have currency: "SAR" —
// safe to re-run, it's a no-op once everything's migrated.
//
// Defaults to a dry run (reports what would change, writes nothing).
// Pass --apply to actually commit the writes.
//
// Usage:
//   FIREBASE_PROJECT_ID=booking-app-36b8e node scripts/migrate-currency-to-egp.js
//   FIREBASE_PROJECT_ID=booking-app-36b8e node scripts/migrate-currency-to-egp.js --apply
//
// Picks up credentials the normal way: `gcloud auth application-default
// login` or a GOOGLE_APPLICATION_CREDENTIALS service-account key. Defaults
// to the safe "demo-" emulator project if FIREBASE_PROJECT_ID isn't set.
const admin = require("firebase-admin");

const projectId = process.env.FIREBASE_PROJECT_ID || "demo-swim-academy";
const apply = process.argv.includes("--apply");

admin.initializeApp({ projectId });
const db = admin.firestore();

const COLLECTIONS = ["classes", "packages", "transactions"];

async function migrateCollection(name) {
  const snap = await db.collection(name).where("currency", "==", "SAR").get();
  console.log(`${name}: ${snap.size} document(s) with currency: "SAR"`);
  if (snap.empty || !apply) return snap.size;

  // Firestore batches cap at 500 writes; chunk defensively even though
  // none of these collections are expected to be anywhere near that.
  const docs = snap.docs;
  for (let i = 0; i < docs.length; i += 500) {
    const batch = db.batch();
    for (const doc of docs.slice(i, i + 500)) {
      batch.update(doc.ref, { currency: "EGP" });
    }
    await batch.commit();
  }
  console.log(`${name}: updated ${docs.length} document(s) to "EGP"`);
  return snap.size;
}

async function main() {
  console.log(`Project: ${projectId}`);
  console.log(apply ? "Mode: APPLY (writing changes)" : "Mode: DRY RUN (no writes — pass --apply to commit)");
  console.log("");

  let total = 0;
  for (const name of COLLECTIONS) {
    total += await migrateCollection(name);
  }

  console.log("");
  console.log(`Total matching documents: ${total}`);
  if (!apply && total > 0) {
    console.log("Re-run with --apply to update them.");
  }
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
