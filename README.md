# Swim Academy Platform

A CMS-driven booking platform for a swimming academy in Saudi Arabia: one Firebase backend shared by a Flutter mobile app (customers) and a Flutter Web admin dashboard (staff). Full English/Arabic (RTL) support throughout.

See [docs/architecture.md](docs/architecture.md) for the full system design, data model, and current build status.

## Repo layout
- **`mobile-app/`** — Flutter app (iOS + Android). Register, browse classes, book sessions, manage family members, buy packages — wired to the real Firebase backend.
- **`admin-dashboard/`** — Flutter Web staff dashboard. Classes & Calendar, Banners, Packages, App Content & Settings, Members, Instructors, Payments & Reports, Notification Center, Requests, Staff Accounts.
- **`backend/`** — Firebase: Cloud Functions (TypeScript), Firestore security rules and indexes.
- **`shared/`** — pure-Dart package with the data models used by both `mobile-app` and `admin-dashboard`, kept in sync by hand with `backend/functions/src/models/types.ts`.

Both apps point at the real, deployed Firebase project (`booking-app-36b8e`) by default — admin dashboard is live at https://booking-app-36b8e.web.app. See [docs/architecture.md](docs/architecture.md) for running everything against the local emulator suite instead, deployment commands, and the full build status.

## Running the mobile app
```
cd mobile-app
flutter pub get
flutter run
```

## Running the admin dashboard
```
cd admin-dashboard
flutter pub get
flutter run -d chrome
```

## Running the backend locally (emulator)
```
cd backend/functions && npm install && npm run build
cd backend && npx firebase-tools emulators:start --project demo-swim-academy
```
Then seed demo data and a first admin account:
```
cd backend/functions
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 FIREBASE_AUTH_EMULATOR_HOST=127.0.0.1:9099 node scripts/seed.js   # admin@swimacademy.test / admin123456
```
Flip `kUseFirebaseEmulators = true` in each app's `lib/core/firebase/firebase_bootstrap.dart` to point them at the emulator instead of production.
