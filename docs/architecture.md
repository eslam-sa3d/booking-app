# Swim Academy Platform — Architecture

## System overview
Three parts, one backend:
1. **Backend** (`backend/`) — Firebase: Auth, Firestore, Cloud Functions, Cloud Messaging, Storage. The single source of truth. Deployed to the real project `booking-app-36b8e` (Blaze plan).
2. **Mobile app** (`mobile-app/`) — Flutter, iOS + Android, customer-facing.
3. **Admin dashboard** (`admin-dashboard/`) — Flutter Web, staff-facing. Fully controls what the mobile app shows — no app-store release needed to change content. Deployed at https://booking-app-36b8e.web.app.

Everything CMS-driven: classes, sessions, pricing, packages, categories, banners, and static content live in Firestore and are edited from the admin dashboard. The mobile app only fetches and renders what the backend sends it. Full English/Arabic (RTL) support throughout, since the academy operates in Saudi Arabia.

## Repo layout
```
swimming-academy/
├── backend/                  # Firebase: Cloud Functions (TypeScript), Firestore/Storage rules & indexes
│   └── functions/
│       ├── src/
│       │   ├── models/types.ts        # Firestore schema — TS mirror of shared/lib/src/*.dart
│       │   ├── lib/admin.ts           # firebase-admin singleton
│       │   ├── lib/audit.ts           # auditLog trigger factory (see "Audit logging" below)
│       │   ├── lib/notify.ts          # shared inbox-write + FCM-push helper, preference-aware
│       │   ├── auth/                  # onUserCreate, assignStaffRole
│       │   ├── admin/adminDelete.ts   # audited delete callable (see "Audit logging" below)
│       │   ├── audit/triggers.ts      # one auditLog trigger per audited collection
│       │   ├── bookings/              # onBookingCreate, onBookingCancel (capacity + waitlist)
│       │   ├── notifications/dispatch.ts   # broadcast -> inbox + FCM fan-out, segments, scheduling
│       │   ├── scheduled/packageExpiryReminders.ts
│       │   ├── scheduled/sessionReminders.ts  # 2h-before-session reminder
│       │   ├── payments/webhook.ts    # stub — see "Status" below
│       │   └── index.ts
│       └── scripts/          # seed.js, smoke-test.js
├── mobile-app/                # Flutter customer app — all 17 screens, wired to the real backend
├── admin-dashboard/           # Flutter Web staff dashboard — 12 modules incl. Reports & Analytics
├── shared/                    # pure-Dart package: models shared by mobile-app and admin-dashboard
└── docs/architecture.md       # this file
```

## Data models (Firestore collections)
See `backend/functions/src/models/types.ts` for the authoritative TypeScript shape and `shared/lib/src/*.dart` for the Dart side — keep both in sync by hand when a model changes.

| Collection | Notes |
|---|---|
| `users/{uid}` | profile + `role: customer\|staff\|admin` (mirror of the Auth custom claim, not authoritative) + `fcmTokens: string[]` + `notificationPreferences: {reminders, promotions, announcements}` |
| `users/{uid}/familyMembers/{id}` | children/dependents a customer books for; `badges`/`progressNotes` are staff-awarded from the admin dashboard's Members screen |
| `users/{uid}/packages/{id}` | owned package instances (remaining sessions, expiry) |
| `users/{uid}/inbox/{id}` | per-user delivered notification copies; `sourceNotificationId` links back to the originating `notifications/{id}` for delivery/read stats |
| `classes/{id}` | catalog, staff/admin managed, guest-readable; `categories: string[]` references `categories/{id}` docs |
| `categories/{id}` | admin-managed class taxonomy (`nameEn`, `nameAr`, `order`) — replaces what used to be a fixed Dart enum |
| `sessions/{id}` | a bookable occurrence of a class; `bookedCount`/`waitlistCount` are Cloud-Function-owned; instructor/branch can override the parent class's defaults per-session |
| `blockedDates/{id}` | a date (optionally scoped to one branch) closed to new sessions/bookings; bulk recurring-session creation skips these |
| `bookings/{id}` | one booking per participant per session |
| `packages/{id}` | package catalog (session packs, unlimited, private) |
| `transactions/{id}` | payment records; `refundRequestStatus`/`refundRequestedAt`/`refundRequestReason`/`refundResolvedBy` back the refund-request queue |
| `banners/{id}`, `instructors/{id}`, `branches/{id}` | CMS content, admin-editable, live in the mobile app instantly |
| `reviews/{id}` | post-session ratings — also used to compute an instructor's real average rating |
| `notifications/{id}` | staff-authored broadcast definitions — writing here triggers `onNotificationCreated`; `status: scheduled` + `scheduledFor` defers to `dispatchScheduledNotifications` |
| `appSettings/config` | singleton: branding, FAQ, terms, contact info — admin-only write, publicly readable, live-consumed by the mobile app |
| `auditLog/{id}` | server-write only, records every staff/admin write across the audited collections (see "Audit logging" below) |
| `sentPackageExpiryReminders/{userPackageId}`, `sentSessionReminders/{bookingId}` | server-write only, dedupe markers for the two reminder scheduled functions |

## Auth & roles
Role is a **Firebase Auth custom claim**, set server-side only:
- `onUserCreate` (Auth trigger) grants every new account `role: customer` and mirrors it into `users/{uid}.role` for display/query convenience.
- `assignStaffRole` (admin-only callable) is the only way a role changes after that — used by the admin dashboard's Staff Accounts screen.
- `firestore.rules` checks `request.auth.token.role`, never the mirrored Firestore field, so a customer can't grant themselves access by editing their own document.
- **Admin dashboard permission matrix**: `staff` and `admin` both reach Dashboard, Requests, Classes, Calendar, Categories, Banners, Packages, Members, Instructors, and Notifications. `admin`-only: Payments, Reports & Analytics, App Content & Settings, Staff Accounts — enforced both in `admin-dashboard/lib/core/router/access.dart` (redirect + hidden sidebar entries) and in `firestore.rules` (`transactions`/`appSettings` writes require `isAdmin()`, not just `isStaff()`).

## Audit logging
Every staff/admin **create/update** on an audited collection (`classes`, `sessions`, `banners`, `packages`, `instructors`, `categories`, `blockedDates`, `appSettings`, `transactions`, and staff-initiated `users` changes like suspend/reactivate) must include an `updatedBy` field — `firestore.rules` requires it to equal the caller's own uid, so it can't be forged, and a matching Firestore trigger (`backend/functions/src/audit/triggers.ts`) reads it as the `auditLog` entry's actor. **Deletes** carry no document payload for `updatedBy` to live on, so the admin dashboard routes all deletes through the `adminDelete` callable (`backend/functions/src/admin/adminDelete.ts`) instead, which deletes via the Admin SDK and logs with a verified actor from its own auth context. On the Flutter side, every admin-dashboard repository mixes in `AuditedWrite` (`admin-dashboard/lib/data/repositories/audited_write.dart`) to apply this consistently.

## Booking capacity & waitlist
`onBookingCreate` and `onBookingCancel` (Firestore triggers, `backend/functions/src/bookings/`) are the authoritative owners of a session's `bookedCount`/`waitlistCount` and a booking's `status`. Both run inside Firestore transactions so concurrent bookings can't over-fill a session, and cancelling a confirmed booking atomically promotes the earliest waitlisted booking for that session. The mobile app enforces a 24-hour cancellation cutoff client-side before calling the repository (backed by the session's real start time). Both mobile-app's `FirebaseBookingRepository` and the admin dashboard's `BookingsRepository` write client-optimistic booking docs and let the Cloud Function correct them — the client never computes final status itself.

## Notifications
A shared `notifyUsers()` helper (`backend/functions/src/lib/notify.ts`) writes an in-app inbox copy and sends an FCM push together, respecting each user's `notificationPreferences` (transactional types like booking confirmation are never gated; `reminder`/`packageExpiry` respect the `reminders` toggle, `promotion` respects `promotions`, `general` respects `announcements`). It's used by:
- `onBookingCreate`/`onBookingCancel` — confirmation, waitlist-add, cancellation, and waitlist-promotion pushes.
- `packageExpiryReminders` (daily) and `sessionReminders` (every 15 min, fires ~2h before a session starts) — both dedupe via a marker collection so reruns are safe.
- `onNotificationCreated`/`dispatchScheduledNotifications` — staff broadcasts from the admin dashboard's Notification Center. Targeting supports all customers, a single user, or a named segment (`expiringPackageThisWeek`, `noBookingInLast30Days`, both computed live). A broadcast created with `status: 'scheduled'` + `scheduledFor` is picked up by the scheduled function once its time arrives instead of sending immediately; delivery/read counts are computed on demand via a `collectionGroup('inbox')` query on `sourceNotificationId`.

The mobile app registers its FCM token on login (`mobile-app/lib/core/notifications/fcm_token_registrar.dart`) and shows foreground pushes via a local-notification handler (`mobile-app/lib/core/notifications/push_notification_handler.dart`), which also deep-links a tapped notification to My Bookings or the inbox.

## Status
**Fully built and deployed to the real Firebase project (`booking-app-36b8e`), not just the emulator:**
- **Backend**: full Firestore/Storage schema and security rules, audit logging on every staff/admin write, role-based permission matrix, real FCM push across every notification type, segment/scheduled broadcast targeting, session/package expiry reminders.
- **Mobile app**: all 17 screens, full EN/AR RTL, Riverpod + go_router, platform-adaptive UI (Liquid Glass on iOS / Material 3 on Android), real Firebase Phone Auth OTP, Google Sign-In, 24h cancellation policy enforcement, add-to-device-calendar, in-app receipts, package renewal, self-service refund requests, editable profile (email + photo upload to Storage), synced language preference, per-category notification preference toggles, FAQ/terms/contact live from `appSettings` (no more hardcoded content), live banner carousel, branch filtering, offline-cached class list with a "load more" pager, and Firebase Analytics on registration/login/booking/payment events. Checkout no longer collects raw card details anywhere — card payment is disabled pending a real gateway (see "Explicitly deferred").
- **Admin dashboard**: all 12 modules — Dashboard Overview (incl. today's bookings, revenue this month, upcoming sessions, low-capacity classes, expiring packages), Requests (waitlist/cancellations + a refund-request approval queue), Calendar & Class Management (incl. bulk recurring creation that skips blocked dates, per-session instructor/pool override), Categories (CRUD + reorder), Banners (incl. active date range + live preview), Payments (date/class filters + a revenue-by-month/class report), Members (edit profile, payment history, badge/progress-note awarding), Instructors (real computed rating from reviews, per-instructor schedule view), Notification Center (segment/single-user targeting, scheduling, delivery/read stats), App Content & Settings, Staff Accounts, and Reports & Analytics (bookings trend, attendance rate, popular classes/times, revenue trend, member growth).
- `shared/` Dart package with every model (Firestore-serializable via `toMap`/`fromMap`), consumed by both `mobile-app` and `admin-dashboard`.
- Android build validated with all native dependencies (Google Sign-In, Firebase Storage, image_picker, add_2_calendar pinned to `3.0.1` — later versions ship a broken Kotlin-DSL Gradle file, see the package's `android/build.gradle.kts`, missing an `id("org.jetbrains.kotlin.android")` plugin application; watch for this on any future version bump). iOS build validated after a `pod repo update` + clean `Podfile.lock` regeneration (needed once, after adding the new native pods).

**Explicitly deferred:**
- `backend/functions/src/payments/webhook.ts` — real payment gateway integration (Moyasar/HyperPay/Stripe TBD, deliberately not chosen yet). Checkout only offers Mada/Apple Pay/STC Pay through `mobile-app`'s simulated `MockPaymentService`; the credit-card option and all raw card fields have been removed from the UI rather than left half-wired.
- **Apple Sign-In** — blocked on enrolling in the Apple Developer Program ($99/yr), a step only the account owner can take.
- **Google Sign-In** — code is complete and correct, but needs two manual console steps before it works end-to-end: enabling the Google provider in Firebase Authentication, and registering the Android app's SHA-1 signing fingerprint.
- **Real end-to-end Phone Auth SMS on iOS** — the Dart/Firebase side is fully implemented, but Apple's silent-push/reCAPTCHA fallback needs the Push Notifications capability + APNs configured natively in Xcode, which can't be done from code.
- Multi-environment (dev/staging/prod) Firebase projects — deliberately deferred; everything currently runs on one production project (see "Environments" below).

## Environments
Everything — mobile app, admin dashboard, and your own local testing — currently points at the single real Firebase project `booking-app-36b8e` (Blaze plan). `backend/.firebaserc.example` shows the shape for a real dev/staging/prod split if that becomes necessary later; each additional environment needs its own Blaze-enabled project (Cloud Functions require it) and a `flutterfire configure` run from `mobile-app/` and `admin-dashboard/` to generate that environment's `firebase_options.dart`.

The local Firebase Emulator Suite still works for offline development (`backend/functions/scripts/seed.js` defaults to the safe `demo-swim-academy` "demo-" project id, which the Admin SDK refuses to let touch real infrastructure). Because `.firebaserc`'s default project is the real one, **launch the emulators with an explicit override** — `firebase emulators:start --project demo-swim-academy` — otherwise the Auth emulator's project id won't match what `seed.js`/`smoke-test.js` expect and account creation will fail.

## Running the backend locally (emulator)
```
cd backend/functions && npm install && npm run build
cd backend && npx firebase-tools emulators:start --project demo-swim-academy
```
Requires a JDK on PATH (the Firestore/Auth emulators run on the JVM) — `brew install openjdk` if `java -version` fails, and put it on PATH for that shell: `export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"`.

With the emulators running:
- `cd backend/functions && FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 node scripts/seed.js` — creates a first admin account (`admin@swimacademy.test` / `admin123456`) and demo CMS content.
- `cd backend/functions && FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 npm run smoke-test` — exercises the auth-claim + booking-capacity/waitlist flow end-to-end, a good regression check after touching any Cloud Function.

To seed/reset the **real production project** instead, run `seed.js` with `FIREBASE_PROJECT_ID=booking-app-36b8e` and real credentials (`gcloud auth application-default login` or a service-account key) — it picks up credentials the normal way; the "demo-" default is purely a local-safety fallback.

## Running the apps
Against the real backend (default — `kUseFirebaseEmulators = false` in both apps):
```
cd mobile-app && flutter run
cd admin-dashboard && flutter run -d chrome
```
Against the local emulator instead, flip `kUseFirebaseEmulators` to `true` in each app's `lib/core/firebase/firebase_bootstrap.dart`. On a physical device (not simulator/emulator), pass `--dart-define=EMULATOR_HOST=<your-Mac's-LAN-IP>` so the app can reach the emulator over Wi-Fi — `backend/firebase.json` already binds the emulators to `0.0.0.0` for this.

## Deploying
```
cd backend && firebase deploy --only firestore:rules,firestore:indexes,storage,functions --project booking-app-36b8e
cd admin-dashboard && flutter build web --release && firebase deploy --only hosting --project booking-app-36b8e
```
Android release builds: `cd mobile-app && flutter build apk --release` (or `appbundle`), then distribute via `firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk --app <android-app-id> --testers <emails> --project booking-app-36b8e`. iOS distribution needs an Apple Developer account (see "Explicitly deferred").
