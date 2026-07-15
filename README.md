# Swim Academy Platform

A CMS-driven booking platform for a swimming academy in Saudi Arabia: one Firebase backend shared by a Flutter mobile app (customers) and a Flutter Web admin dashboard (staff). Full English/Arabic (RTL) support throughout.

See [docs/architecture.md](docs/architecture.md) for the full system design, data model, and current build status.

## Repo layout
- **`mobile-app/`** — Flutter app (iOS + Android). Register, browse classes, book sessions, manage family members, buy packages. Currently runs on an in-memory mock data layer; see the app's own docs for how to swap in the real backend.
- **`backend/`** — Firebase: Cloud Functions (TypeScript), Firestore security rules and indexes.
- **`admin-dashboard/`** — Flutter Web staff dashboard (not yet built).
- **`shared/`** — pure-Dart package with the data models used by both `mobile-app` and `admin-dashboard`, kept in sync by hand with `backend/functions/src/models/types.ts`.

## Running the mobile app
```
cd mobile-app
flutter pub get
flutter run
```

## Running the backend
```
cd backend/functions
npm install
npm run build
cd ..
npx firebase-tools emulators:start   # Firestore + Functions + Auth emulators, no real Firebase project needed
```

To point either app at a real Firebase project, copy `backend/.firebaserc.example` to `backend/.firebaserc` with your project IDs, then run `flutterfire configure` from `mobile-app/`.
