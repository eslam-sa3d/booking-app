import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:booking_app/app.dart';
import 'package:booking_app/core/providers/shared_preferences_provider.dart';

import 'test_overrides.dart';

void main() {
  testWidgets('App boots to the home screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs), ...testRepositoryOverrides],
        child: const SwimAcademyApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byIcon(Icons.pool_rounded), findsWidgets);
  });
}
