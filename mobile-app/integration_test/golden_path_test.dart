import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:booking_app/app.dart';
import 'package:booking_app/core/providers/shared_preferences_provider.dart';

import '../test/test_overrides.dart';

Future<void> _boot(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs), ...testRepositoryOverrides],
      child: const SwimAcademyApp(),
    ),
  );
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('golden path: onboarding -> home -> class details -> calendar -> login -> Arabic RTL', (tester) async {
    await _boot(tester);

    // Onboarding -> Skip to Home.
    expect(find.text('Skip'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Home renders class cards.
    expect(find.text('Featured classes'), findsOneWidget);
    await tester.pumpAndSettle();

    // Tap the first class card -> Class Details.
    final classCard = find.text('Kids Beginner Splash').first;
    expect(classCard, findsOneWidget);
    await tester.tap(classCard);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('About this class'), findsWidgets);

    // Back to Home, then Calendar tab.
    await tester.pageBack();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Booking calendar'), findsOneWidget);

    // Profile tab -> logged-out prompt -> Login screen.
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Log in'), findsWidgets);
    await tester.tap(find.text('Log in').last);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Welcome back'), findsOneWidget);

    // Log in with the seeded demo account.
    await tester.enterText(find.byType(TextFormField).first, 'eslamsa3d@hotmail.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Log in').last);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Hello, Eslam'), findsOneWidget);

    // My Bookings tab shows the seeded booking.
    await tester.tap(find.text('Bookings'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('My bookings'), findsOneWidget);

    // Profile -> Settings -> switch to Arabic, verify RTL.
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final directionality = tester.widget<Directionality>(
      find.byType(Directionality).first,
    );
    expect(directionality.textDirection, TextDirection.rtl);
  });
}
