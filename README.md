# Swim Academy Platform

A CMS-driven booking platform for a swimming academy in Saudi Arabia: one Firebase backend shared by a Flutter mobile app (customers) and a Flutter Web admin dashboard (staff). Full English/Arabic (RTL) support throughout.

See [docs/architecture.md](docs/architecture.md) for the full system design, data model, and current build status.

## Repo layout
- **`mobile-app/`** — Flutter app (iOS + Android). Register, browse classes, book sessions, manage family members, buy packages — wired to the real Firebase backend.
- **`admin-dashboard/`** — Flutter Web staff dashboard. Classes & Calendar, Banners, Packages, App Content & Settings, Members, Instructors, Payments & Reports, Notification Center, Requests, Staff Accounts.
- **`backend/`** — Firebase: Cloud Functions (TypeScript), Firestore security rules and indexes.
- **`shared/`** — pure-Dart package with the data models used by both `mobile-app` and `admin-dashboard`, kept in sync by hand with `backend/functions/src/models/types.ts`.

Both apps default to the local Firebase emulator suite (no real Firebase project needed) — start the backend first.

## Running the backend
```
cd backend/functions
npm install
npm run build
cd ..
npx firebase-tools emulators:start   # Firestore + Functions + Auth emulators
```
Then seed demo data and a first admin account:
```
cd backend/functions
node scripts/seed.js   # admin@swimacademy.test / admin123456
```

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

## Pointing at a real Firebase project
Copy `backend/.firebaserc.example` to `backend/.firebaserc` with your project IDs, run `flutterfire configure` from `mobile-app/` and `admin-dashboard/` to replace their placeholder `firebase_options.dart`, then set `kUseFirebaseEmulators = false` in each app's `lib/core/firebase/firebase_bootstrap.dart`.
