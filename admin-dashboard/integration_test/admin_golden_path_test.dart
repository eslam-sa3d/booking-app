// Drives the real admin dashboard against the local Firebase emulator
// suite — proves the auth-gated Flutter Web app actually works end to
// end: sign in as the seeded admin -> dashboard loads live stats ->
// create a class -> it appears in the list -> create a banner -> it
// appears in the list. Requires the emulators running and
// `node backend/functions/scripts/seed.js` already run at least once
// (for the admin@swimacademy.test account).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:admin_dashboard/app.dart';
import 'package:admin_dashboard/core/firebase/firebase_bootstrap.dart';

/// pumpAndSettle alone can return before a Firestore round-trip finishes —
/// poll with real-time pumps instead (see mobile-app's equivalent test).
Future<void> _waitFor(WidgetTester tester, Finder finder, {int maxTries = 40}) async {
  for (var i = 0; i < maxTries && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('admin: sign in -> dashboard -> create class -> create banner', (tester) async {
    await bootstrapFirebase();

    await tester.pumpWidget(const ProviderScope(child: AdminApp()));
    await _waitFor(tester, find.text('Sign in'));

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(2));
    await tester.enterText(fields.at(0), 'admin@swimacademy.test');
    await tester.enterText(fields.at(1), 'admin123456');
    await tester.tap(find.text('Sign in'));
    await _waitFor(tester, find.text('Dashboard'));

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Active classes'), findsOneWidget);

    // Classes: seeded classes render, then add a new one.
    await tester.tap(find.text('Classes'));
    await _waitFor(tester, find.text('Kids Beginner Splash'));
    expect(find.text('Kids Beginner Splash'), findsOneWidget);

    final className = 'Integration Test Class ${DateTime.now().millisecondsSinceEpoch}';
    await tester.tap(find.text('Add class'));
    await tester.pumpAndSettle();
    final classFields = find.byType(TextFormField);
    await tester.enterText(classFields.at(0), className);
    await tester.enterText(classFields.at(1), '$className (AR)');
    await tester.tap(find.text('kids'));
    await tester.enterText(classFields.at(4), '199');
    await tester.enterText(classFields.at(5), '45');
    await tester.enterText(classFields.at(6), 'i1');
    await tester.enterText(classFields.at(7), 'b1');
    await tester.tap(find.text('Save'));
    await _waitFor(tester, find.text(className));
    expect(find.text(className), findsOneWidget);

    // Banners: add one, confirm it renders.
    await tester.tap(find.text('Banners'));
    await tester.pumpAndSettle();
    final bannerTitle = 'Test Banner ${DateTime.now().millisecondsSinceEpoch}';
    await tester.tap(find.text('Add banner'));
    await tester.pumpAndSettle();
    final bannerFields = find.byType(TextFormField);
    await tester.enterText(bannerFields.at(0), bannerTitle);
    await tester.tap(find.text('Save'));
    await _waitFor(tester, find.text(bannerTitle));
    expect(find.text(bannerTitle), findsOneWidget);
  });
}
