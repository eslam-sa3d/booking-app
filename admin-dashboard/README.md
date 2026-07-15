# Admin Dashboard

Flutter Web staff dashboard, sharing data models with `../mobile-app` via `../shared`. See [../docs/architecture.md](../docs/architecture.md) for the full system design.

Auth-gated by the `staff`/`admin` Firebase Auth custom claim (set server-side — see `backend/functions/src/auth/`). Modules: Dashboard overview, Requests (waitlist/cancellations), Classes, Calendar & Sessions (incl. bulk recurring creation), Banners, Packages & Pricing, Payments & Reports, Members, Instructors, Notification Center, App Content & Settings, Staff Accounts.

## Run against the local emulator
```
flutter pub get
flutter run -d chrome
```
Requires the backend emulators running and seeded — see the root [README](../README.md). Sign in with the seeded admin account (`admin@swimacademy.test` / `admin123456`) or promote another account via Staff Accounts once signed in as an admin.

## Integration test
`integration_test/admin_golden_path_test.dart` drives the real app against the real emulator (sign in → dashboard → create a class → create a banner). Web integration tests need `flutter drive`, not `flutter test`:
```
brew install --cask chromedriver   # if not already installed; may need `xattr -d com.apple.quarantine $(which chromedriver)` on macOS
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/admin_golden_path_test.dart -d chrome
```
