import 'package:flutter_test/flutter_test.dart';
import 'package:hoopsleague/utils/odds_converter.dart';

void main() {
  group('OddsConverter', () {
    group('FR format (decimal)', () {
      test('should return decimal with 2 decimals', () {
        expect(OddsConverter.convert(1.85, 'FR'), '1.85');
        expect(OddsConverter.convert(2.50, 'FR'), '2.50');
        expect(OddsConverter.convert(1.50, 'FR'), '1.50');
      });

      test('should round to 2 decimals', () {
        expect(OddsConverter.convert(1.856, 'FR'), '1.86');
        expect(OddsConverter.convert(2.123, 'FR'), '2.12');
      });

      test('should handle whole numbers', () {
        expect(OddsConverter.convert(2.00, 'FR'), '2.00');
        expect(OddsConverter.convert(3.00, 'FR'), '3.00');
      });
    });

    group('UK format (fractional)', () {
      test('should convert simple fractions correctly', () {
        expect(OddsConverter.convert(2.00, 'UK'), '1/1'); // Even money
        expect(OddsConverter.convert(3.00, 'UK'), '2/1'); // 2 to 1
        expect(OddsConverter.convert(1.50, 'UK'), '1/2'); // 1 to 2
      });

      test('should convert complex fractions', () {
        // 1.85 - 1 = 0.85 ≈ 17/20
        final result = OddsConverter.convert(1.85, 'UK');
        expect(result, contains('/'));

        // Verify it's a valid fraction that approximates 0.85
        final parts = result.split('/');
        expect(parts.length, 2);
        final num = int.parse(parts[0]);
        final den = int.parse(parts[1]);
        expect(num / den, closeTo(0.85, 0.05));
      });

      test('should handle odds close to 1', () {
        expect(OddsConverter.convert(1.10, 'UK'), '1/10');
        expect(OddsConverter.convert(1.20, 'UK'), '1/5');
      });

      test('should handle high odds', () {
        expect(OddsConverter.convert(10.00, 'UK'), '9/1');
        expect(OddsConverter.convert(5.00, 'UK'), '4/1');
      });
    });

    group('US format (American)', () {
      test('should convert odds >= 2.0 to positive American odds', () {
        expect(OddsConverter.convert(2.00, 'US'), '+100');
        expect(OddsConverter.convert(3.00, 'US'), '+200');
        expect(OddsConverter.convert(2.50, 'US'), '+150');
      });

      test('should convert odds < 2.0 to negative American odds', () {
        expect(OddsConverter.convert(1.50, 'US'), '-200');
        expect(OddsConverter.convert(1.85, 'US'), '-118');
        expect(OddsConverter.convert(1.10, 'US'), '-1000');
      });

      test('should handle edge case at 2.0', () {
        expect(OddsConverter.convert(2.00, 'US'), '+100');
      });

      test('should handle edge case at 1.0 (no profit)', () {
        expect(OddsConverter.convert(1.0, 'US'), '±0');
      });
    });

    group('Edge cases', () {
      test('should handle very low odds', () {
        expect(OddsConverter.convert(1.01, 'FR'), '1.01');
        expect(OddsConverter.convert(1.01, 'UK'), contains('/'));
        expect(OddsConverter.convert(1.01, 'US').startsWith('-'), true);
      });

      test('should handle very high odds', () {
        expect(OddsConverter.convert(10.00, 'FR'), '10.00');
        expect(OddsConverter.convert(10.00, 'UK'), '9/1');
        expect(OddsConverter.convert(10.00, 'US'), '+900');
      });

      test('should default to FR format for unknown format', () {
        expect(OddsConverter.convert(1.85, 'UNKNOWN'), '1.85');
        expect(OddsConverter.convert(2.50, 'XYZ'), '2.50');
      });

      test('should be case insensitive', () {
        expect(OddsConverter.convert(2.00, 'fr'), '2.00');
        expect(OddsConverter.convert(2.00, 'uk'), '1/1');
        expect(OddsConverter.convert(2.00, 'us'), '+100');
        expect(OddsConverter.convert(2.00, 'Fr'), '2.00');
        expect(OddsConverter.convert(2.00, 'Uk'), '1/1');
        expect(OddsConverter.convert(2.00, 'Us'), '+100');
      });
    });

    group('Real world betting scenarios', () {
      test('typical NBA favorite odds', () {
        // Lakers as slight favorites
        expect(OddsConverter.convert(1.65, 'FR'), '1.65');
        expect(OddsConverter.convert(1.65, 'US'), '-154');
      });

      test('typical NBA underdog odds', () {
        // Celtics as underdogs
        expect(OddsConverter.convert(2.35, 'FR'), '2.35');
        expect(OddsConverter.convert(2.35, 'US'), '+135');
      });

      test('close match odds', () {
        expect(OddsConverter.convert(1.90, 'FR'), '1.90');
        expect(OddsConverter.convert(1.95, 'FR'), '1.95');
      });
    });
  });
}
