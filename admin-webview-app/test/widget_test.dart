import 'package:flutter_test/flutter_test.dart';

import 'package:booking_admin_webview/main.dart';

void main() {
  group('isAllowedNavigation', () {
    test('allows the admin dashboard host', () {
      expect(
        isAllowedNavigation('https://booking-app-36b8e.web.app/bookings'),
        isTrue,
      );
    });

    test('rejects other hosts', () {
      expect(isAllowedNavigation('https://evil.example.com'), isFalse);
      expect(isAllowedNavigation('https://google.com'), isFalse);
    });

    test('rejects unparseable urls', () {
      expect(isAllowedNavigation(''), isFalse);
    });
  });
}
