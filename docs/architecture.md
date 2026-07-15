# Swim Academy Platform — Architecture

## System overview
Three parts, one backend:
1. **Backend** (`backend/`) — Firebase: Auth, Firestore, Cloud Functions, Cloud Messaging. The single source of truth.
2. **Mobile app** (`mobile-app/`) — Flutter, iOS + Android, customer-facing.
3. **Admin dashboard** (`admin-dashboard/`) — Flutter Web, staff-facing. Fully controls what the mobile app shows — no app-store release needed to change content.

Everything CMS-driven: classes, sessions, pricing, packages, banners, and static content live in Firestore and are edited from the admin dashboard. The mobile app only fetches and renders what the backend sends it. Full English/Arabic (RTL) support throughout, since the academy operates in Saudi Arabia.

## Repo layout
```
swimming-academy/
├── backend/                  # Firebase: Cloud Functions (TypeScript), Firestore rules/indexes
│   └── functions/
│       ├── src/
│       │   ├── models/types.ts        # Firestore schema — TS mirror of shared/lib/src/*.dart
│       │   ├── lib/admin.ts           # firebase-admin singleton
│       │   ├── auth/                  # onUserCreate, assignStaffRole
│       │   ├── bookings/              # onBookingCreate, onBookingCancel (capacity + waitlist)
│       │   ├── notifications/dispatch.ts   # broadcast -> inbox + FCM fan-out
│       │   ├── scheduled/packageExpiryReminders.ts
│       │   ├── payments/webhook.ts    # stub — see "Status" below
│       │   └── index.ts
│       └── scripts/          # seed.js, smoke-test.js — emulator-only dev tools
├── mobile-app/                # Flutter customer app — all 17 screens, wired to the real backend
├── admin-dashboard/           # Flutter Web staff dashboard — Classes/Calendar, Banners, Packages,
│                               # Settings, Members, Instructors, Payments/Reports, Notifications,
│                               # Requests, Staff Accounts
├── shared/                    # pure-Dart package: models shared by mobile-app and admin-dashboard
└── docs/architecture.md       # this file
```

## Data models (Firestore collections)
See `backend/functions/src/models/types.ts` for the authoritative TypeScript shape and `shared/lib/src/*.dart` for the Dart side — keep both in sync by hand when a model changes.

| Collection | Notes |
|---|---|
| `users/{uid}` | profile + `role: customer\|staff\|admin` (mirror of the Auth custom claim, not authoritative) + `fcmTokens: string[]` |
| `users/{uid}/familyMembers/{id}` | children/dependents a customer books for |
| `users/{uid}/packages/{id}` | owned package instances (remaining sessions, expiry) |
| `users/{uid}/inbox/{id}` | per-user delivered notification copies |
| `classes/{id}` | catalog, staff/admin managed, guest-readable |
| `sessions/{id}` | a bookable occurrence of a class; `bookedCount`/`waitlistCount` are Cloud-Function-owned |
| `bookings/{id}` | one booking per participant per session |
| `packages/{id}` | package catalog (session packs, unlimited, private) |
| `transactions/{id}` | payment records |
| `banners/{id}`, `instructors/{id}`, `branches/{id}` | CMS content, admin-editable, live in the mobile app instantly |
| `reviews/{id}` | post-session ratings |
| `notifications/{id}` | staff-authored broadcast definitions — writing here triggers `dispatchNotification` |
| `appSettings/config` | singleton: branding, FAQ, terms, contact info |
| `auditLog/{id}` | server-write only, records every admin/staff write |
| `sentPackageExpiryReminders/{userPackageId}` | server-write only, dedupes the daily expiry-reminder scheduled function |

## Auth & roles
Role is a **Firebase Auth custom claim**, set server-side only:
- `onUserCreate` (Auth trigger) grants every new account `role: customer` and mirrors it into `users/{uid}.role` for display/query convenience.
- `assignStaffRole` (admin-only callable) is the only way a role changes after that — used by the admin dashboard's Staff Accounts screen. The very first admin is bootstrapped by `backend/functions/scripts/seed.js` (local/emulator only) or, in a real environment, a one-off script using the Admin SDK.
- `firestore.rules` checks `request.auth.token.role`, never the mirrored Firestore field, so a customer can't grant themselves access by editing their own document.

## Booking capacity & waitlist
`onBookingCreate` and `onBookingCancel` (Firestore triggers, `backend/functions/src/bookings/`) are the authoritative owners of a session's `bookedCount`/`waitlistCount` and a booking's `status`. Both run inside Firestore transactions so concurrent bookings can't over-fill a session, and cancelling a confirmed booking atomically promotes the earliest waitlisted booking for that session. Both mobile-app's `FirebaseBookingRepository` and the admin dashboard's `BookingsRepository` write client-optimistic booking docs and let the Cloud Function correct them — the client never computes final status itself.

## Notifications
`dispatchNotification` fires whenever a `notifications/{id}` doc is created (staff broadcast composed in the admin dashboard's Notification Center, or written directly by other functions). It resolves the target audience, writes an `InboxNotification` copy into each recipient's `users/{uid}/inbox`, and best-effort sends an FCM push to any device tokens on file. `packageExpiryReminders` runs daily and reminds users whose package expires within 3 days, deduped via `sentPackageExpiryReminders`. The mobile app registers its FCM token on login (`mobile-app/lib/core/notifications/fcm_token_registrar.dart`) — failures there (no push entitlement, simulator, etc.) are swallowed since push is best-effort.

## Status
**Built and verified end-to-end against the Firebase emulator suite:**
- Mobile app: all 17 screens, full EN/AR RTL, Riverpod + go_router, platform-adaptive UI (Liquid Glass on iOS / Material 3 on Android). Repositories are real Firebase implementations (`mobile-app/lib/data/datasources/firebase/`) behind the same abstract interfaces; `mobile-app/test/test_overrides.dart` swaps in the mock implementations for widget/unit tests so those stay hermetic.
- `shared/` Dart package with every model (Firestore-serializable via `toMap`/`fromMap`), consumed by both `mobile-app` and `admin-dashboard` via path dependencies.
- Backend: full Firestore schema, security rules, Auth role wiring, booking-capacity/waitlist logic, notification dispatch (inbox + FCM), and package-expiry reminders.
- Admin dashboard (Flutter Web): auth-gated by the `staff`/`admin` custom claim; Classes, Calendar & Sessions (incl. bulk recurring creation), Banners, Packages, App Content & Settings, Members, Instructors, Payments & Reports, Notification Center, Requests (waitlist/cancellations), Staff Accounts.
- `mobile-app/integration_test/firebase_golden_path_test.dart` drives the real app against the real emulator: register (`onUserCreate` provisions the profile) → browse seeded classes → book a session (`onBookingCreate` confirms it) → see it in My Bookings. Passing.

**Explicitly deferred** (see `// TODO(next phase)` in the corresponding files):
- `backend/functions/src/payments/webhook.ts` — real payment gateway integration (Moyasar/HyperPay/Stripe TBD); checkout currently uses `mobile-app`'s simulated `MockPaymentService`.
- Notification segment targeting (`notifications/dispatch.ts` falls back to "all customers" for `target: 'segment'`).
- Reports & Analytics charts beyond the basic revenue/transaction stats already in Payments & Reports.

## Environments
Separate Firebase projects for dev/staging/production. `backend/.firebaserc` currently points at `demo-swim-academy` — a [Firebase emulator "demo" project](https://firebase.google.com/docs/emulator-suite) that needs no real GCP project and is safe to commit. `backend/.firebaserc.example` shows the shape for real environments; once real projects exist, add them there (or via `firebase use --add`) and run `flutterfire configure` from `mobile-app/` and `admin-dashboard/` to replace their placeholder `firebase_options.dart`, then flip `kUseFirebaseEmulators` to `false` in each app's `lib/core/firebase/firebase_bootstrap.dart`.

## Running the backend locally
```
cd backend/functions && npm install && npm run build
cd backend && npx firebase-tools emulators:start   # Firestore + Functions + Auth, no real project needed
```
Requires a JDK on PATH (the Firestore/Auth emulators run on the JVM) — `brew install openjdk` if `java -version` fails.

With the emulators running:
- `cd backend/functions && node scripts/seed.js` — creates a first admin account (`admin@swimacademy.test` / `admin123456`) and demo CMS content (branches, instructors, classes, sessions, packages, banners, app settings). Run this before using the admin dashboard or mobile app against the emulator.
- `cd backend/functions && npm run smoke-test` — exercises the auth-claim + booking-capacity/waitlist flow end-to-end (`backend/functions/scripts/smoke-test.js`), a good regression check after touching any Cloud Function.

## Running the apps against the emulator
```
cd mobile-app && flutter run                 # iOS/Android — connects to 127.0.0.1 (iOS) / 10.0.2.2 (Android emulator)
cd admin-dashboard && flutter run -d chrome   # connects to 127.0.0.1
```
Both default to `kUseFirebaseEmulators = true` in their `firebase_bootstrap.dart`.
