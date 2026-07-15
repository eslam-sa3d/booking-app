// Exercises the REAL Firebase-backed app (no mock overrides) against the
// local emulator suite — proves the Firebase rewire actually works
// end-to-end: register -> onUserCreate provisions the profile -> browse
// seeded classes -> book a session -> onBookingCreate confirms it ->
// My Bookings shows it. Requires the emulators to be running (see
// backend/README) and `node scripts/seed.js` to have populated
// classes/sessions.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:booking_app/app.dart';
import 'package:booking_app/core/firebase/firebase_bootstrap.dart';
import 'package:booking_app/core/providers/shared_preferences_provider.dart';

/// pumpAndSettle alone isn't enough after actions that kick off a Firestore
/// round-trip: a FutureProvider awaiting a network call doesn't schedule a
/// new frame until it resolves, so pumpAndSettle can return before the
/// response arrives. Poll with real-time pumps instead.
Future<void> _waitFor(WidgetTester tester, Finder finder, {int maxTries = 40}) async {
  for (var i = 0; i < maxTries && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('real backend: register -> browse seeded classes -> book -> see in My Bookings', (tester) async {
    await bootstrapFirebase();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const SwimAcademyApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Onboarding -> Skip to Home.
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Seeded class from backend/functions/scripts/seed.js renders.
    expect(find.text('Kids Beginner Splash'), findsWidgets);

    // Register a fresh account.
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(find.text('Log in').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final email = 'flutter-test-${DateTime.now().millisecondsSinceEpoch}@test.com';
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Integration Test');
    await tester.enterText(fields.at(1), email);
    await tester.enterText(fields.at(2), '+966500000001');
    await tester.enterText(fields.at(3), 'password123');
    await tester.enterText(fields.at(4), 'password123');
    await tester.tap(find.text('Register'));
    await _waitFor(tester, find.text('Verify your account'));

    // register() navigates to /otp; any 4-digit code passes the (stubbed) check.
    if (find.text('Verify your account').evaluate().isNotEmpty) {
      await tester.enterText(find.byType(TextField).first, '0000');
      await tester.tap(find.text('Verify'));
      await _waitFor(tester, find.textContaining('Hello,'));
    }

    expect(find.textContaining('Hello,'), findsOneWidget);

    // Open the seeded class and scroll the "Available sessions" cards into
    // view — ListView only builds elements near the viewport, so finders
    // can't see them until they've been scrolled into the cache extent.
    await tester.tap(find.text('Kids Beginner Splash').first);
    await _waitFor(tester, find.text('Available sessions'));

    var bookButtons = find.text('Book now');
    for (var i = 0; i < 10 && bookButtons.evaluate().isEmpty; i++) {
      await tester.drag(find.text('Available sessions'), const Offset(0, -300));
      await tester.pumpAndSettle();
      bookButtons = find.text('Book now');
    }
    expect(bookButtons, findsWidgets);
    await tester.tap(bookButtons.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tester.tap(find.text('Myself'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm booking'));
    // onBookingCreate's Cloud Function trigger + FirebaseBookingRepository's
    // internal poll for the finalized status can take a few real seconds.
    await _waitFor(tester, find.text('Booking confirmed!'));
    expect(find.text('Booking confirmed!'), findsOneWidget);

    await tester.tap(find.text('View my bookings'));
    await _waitFor(tester, find.text('Kids Beginner Splash'));
    expect(find.text('Kids Beginner Splash'), findsWidgets);
  });
}
