import 'package:flutter_test/flutter_test.dart';
import 'package:hoopsleague/services/clock.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  group('Clock', () {
    test('now() should return current time', () {
      final clock = Clock();
      final before = DateTime.now();
      final clockTime = clock.now();
      final after = DateTime.now();

      expect(clockTime.isAfter(before) || clockTime.isAtSameMomentAs(before), true);
      expect(clockTime.isBefore(after) || clockTime.isAtSameMomentAs(after), true);
    });

    test('toLocalTime() should convert UTC to local time', () {
      final clock = Clock();
      final utcTime = DateTime.utc(2024, 1, 15, 12, 0);
      final localTime = clock.toLocalTime(utcTime);

      expect(localTime.isUtc, false);
      expect(localTime.toUtc(), utcTime);
    });
  });

  group('LAClock', () {
    late LAClock laClock;

    setUpAll(() {
      tz.initializeTimeZones();
    });

    setUp(() {
      laClock = LAClock();
    });

    test('should initialize with Los Angeles timezone', () {
      expect(laClock.location.name, 'America/Los_Angeles');
    });

    test('now() should return time in LA timezone', () {
      final laTime = laClock.now();
      expect(laTime is tz.TZDateTime, true);
      expect((laTime as tz.TZDateTime).location.name, 'America/Los_Angeles');
    });

    test('toLocalTime() should convert UTC to LA time', () {
      final utcTime = DateTime.utc(2024, 7, 15, 20, 0); // 8 PM UTC
      final laTime = laClock.toLocalTime(utcTime);

      expect(laTime is tz.TZDateTime, true);
      expect((laTime as tz.TZDateTime).location.name, 'America/Los_Angeles');
      
      // En juillet (PDT), LA est UTC-7
      // 20:00 UTC = 13:00 PDT
      expect(laTime.hour, 13);
    });

    test('toLocalTime() should handle winter time (PST)', () {
      final utcTime = DateTime.utc(2024, 1, 15, 20, 0); // 8 PM UTC en janvier
      final laTime = laClock.toLocalTime(utcTime);

      expect(laTime is tz.TZDateTime, true);
      
      // En janvier (PST), LA est UTC-8
      // 20:00 UTC = 12:00 PST
      expect(laTime.hour, 12);
    });
  });
}
