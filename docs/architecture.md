# Swim Academy Platform — Architecture

## System overview
Three parts, one backend:
1. **Backend** (`backend/`) — Firebase: Auth, Firestore, Cloud Functions, Cloud Messaging, Storage. The single source of truth.
2. **Mobile app** (`mobile-app/`) — Flutter, iOS + Android, customer-facing.
3. **Admin dashboard** (`admin-dashboard/`) — Flutter Web, staff-facing. Fully controls what the mobile app shows — no app-store release needed to change content.

Everything CMS-driven: classes, sessions, pricing, packages, banners, and static content live in Firestore and are edited from the admin dashboard. The mobile app only fetches and renders what the backend sends it. Full English/Arabic (RTL) support throughout, since the academy operates in Saudi Arabia.

## Repo layout
```
swimming-academy/
├── backend/              # Firebase: Cloud Functions (TypeScript), Firestore rules/indexes
│   └── functions/src/
│       ├── models/types.ts        # Firestore schema — TS mirror of shared/lib/src/*.dart
│       ├── lib/admin.ts           # firebase-admin singleton
│       ├── auth/                  # onUserCreate, assignStaffRole
│       ├── bookings/              # onBookingCreate, onBookingCancel (capacity + waitlist)
│       ├── payments/, notifications/, scheduled/   # stubs, see "Status" below
│       └── index.ts
├── mobile-app/            # Flutter customer app (see mobile-app/README or below)
├── admin-dashboard/        # Flutter Web admin panel — not yet built
├── shared/                 # pure-Dart package: models shared by mobile-app and admin-dashboard
└── docs/architecture.md    # this file
```

## Data models (Firestore collections)
See `backend/functions/src/models/types.ts` for the authoritative TypeScript shape and `shared/lib/src/*.dart` for the Dart side — keep both in sync by hand when a model changes.

| Collection | Notes |
|---|---|
| `users/{uid}` | profile + `role: customer\|staff\|admin` (mirror of the Auth custom claim, not authoritative) |
| `users/{uid}/familyMembers/{id}` | children/dependents a customer books for |
| `users/{uid}/packages/{id}` | owned package instances (remaining sessions, expiry) |
| `users/{uid}/inbox/{id}` | per-user delivered notification copies |
| `classes/{id}` | catalog, staff/admin managed, guest-readable |
| `sessions/{id}` | a bookable occurrence of a class; `bookedCount`/`waitlistCount` are Cloud-Function-owned |
| `bookings/{id}` | one booking per participant per session |
| `packages/{id}` | package catalog (session packs, unlimited, private) |
| `transactions/{id}` | payment records |
| `banners/{id}`, `instructors/{id}`, `branches/{id}` | CMS content |
| `reviews/{id}` | post-session ratings |
| `notifications/{id}` | staff-authored broadcast definitions |
| `appSettings/config` | singleton: branding, FAQ, terms, contact info |
| `auditLog/{id}` | server-write only, records every admin/staff write |

## Auth & roles
Role is a **Firebase Auth custom claim**, set server-side only:
- `onUserCreate` (Auth trigger) grants every new account `role: customer` and mirrors it into `users/{uid}.role` for display/query convenience.
- `assignStaffRole` (admin-only callable) is the only way a role changes after that — used by the admin dashboard's future Staff Accounts screen.
- `firestore.rules` checks `request.auth.token.role`, never the mirrored Firestore field, so a customer can't grant themselves access by editing their own document.

## Booking capacity & waitlist
`onBookingCreate` and `onBookingCancel` (Firestore triggers, `backend/functions/src/bookings/`) are the authoritative owners of a session's `bookedCount`/`waitlistCount` and a booking's `status`. Both run inside Firestore transactions so concurrent bookings can't over-fill a session, and cancelling a confirmed booking atomically promotes the earliest waitlisted booking for that session.

## Status
**Built:**
- Mobile app: all 17 screens, full EN/AR RTL, Riverpod + go_router, platform-adaptive UI (Liquid Glass on iOS / Material 3 on Android). Currently runs against an in-memory mock data layer (`mobile-app/lib/data/datasources/mock/`) behind the same repository interfaces the real backend will implement — swapping to Firebase touches only that layer.
- `shared/` Dart package with every model, consumed by `mobile-app` via a path dependency.
- Backend: Firestore schema, security rules, Auth role wiring, and real booking-capacity/waitlist Cloud Functions logic.

**Explicitly deferred (see `// TODO(next phase)` in the corresponding files):**
- `backend/functions/src/payments/webhook.ts` — real payment gateway integration (Moyasar/HyperPay/Stripe TBD)
- `backend/functions/src/notifications/dispatch.ts` — FCM push dispatch + admin broadcast targeting
- `backend/functions/src/scheduled/packageExpiryReminders.ts` — scheduled reminder logic
- Admin dashboard — folder scaffolded only, no screens yet
- Rewiring `mobile-app`'s repository implementations from mock to real Firebase (`firebase_auth`/`cloud_firestore`/`firebase_messaging` aren't in `mobile-app/pubspec.yaml` yet)

## Environments
Separate Firebase projects for dev/staging/production. `backend/.firebaserc.example` shows the expected shape — copy it to `backend/.firebaserc` and fill in real project IDs once those projects exist; both `mobile-app` (via `flutterfire configure`) and `admin-dashboard` should point at the same project per environment.

## Running the backend locally
```
cd backend/functions && npm install && npm run build
cd backend && npx firebase-tools emulators:start   # Firestore + Functions + Auth, no real project needed
```
Requires a JDK on PATH (the Firestore/Auth emulators run on the JVM) — `brew install openjdk` if `java -version` fails.

With the emulators running, `cd backend/functions && npm run smoke-test` exercises the full auth-claim + booking-capacity/waitlist flow end-to-end (`backend/functions/scripts/smoke-test.js`) — a good regression check after touching any Cloud Function.
