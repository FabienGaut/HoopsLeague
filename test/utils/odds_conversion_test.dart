import 'package:flutter_test/flutter_test.dart';

/// Fonction de conversion des cotes extraite de GamesPage pour les tests
String convertOdds(double frOdd, String oddsFormat) {
  switch (oddsFormat.toUpperCase()) {
    case 'FR':
      // Format décimal, on renvoie tel quel
      return frOdd.toStringAsFixed(2);

    case 'UK':
      // UK = (FR - 1) exprimé en fraction
      double fraction = frOdd - 1;
      return _toFraction(fraction);

    case 'US':
      if (frOdd >= 2.0) {
        return '+\${((frOdd - 1) * 100).round()}';
      } else {
        return (-100 / (frOdd - 1)).round().toString();
      }

    default:
      return frOdd.toStringAsFixed(2);
  }
}

String _toFraction(double value) {
  const tolerance = 1.0e-6;
  int numerator = 1;
  int denominator = 1;
  double error = (numerator / denominator - value).abs();

  while (error > tolerance && denominator < 100) {
    if (numerator / denominator < value) {
      numerator++;
    } else {
      denominator++;
      numerator = (value * denominator).round();
    }
    error = (numerator / denominator - value).abs();
  }

  return "$numerator/$denominator";
}

void main() {
  group('Odds Conversion', () {
    group('FR format (decimal)', () {
      test('should return decimal with 2 decimals', () {
        expect(convertOdds(1.85, 'FR'), '1.85');
        expect(convertOdds(2.50, 'FR'), '2.50');
        expect(convertOdds(1.50, 'FR'), '1.50');
      });

      test('should round to 2 decimals', () {
        expect(convertOdds(1.856, 'FR'), '1.86');
        expect(convertOdds(2.123, 'FR'), '2.12');
      });
    });

    group('UK format (fractional)', () {
      test('should convert simple fractions correctly', () {
        expect(convertOdds(2.00, 'UK'), '1/1'); // Even money
        expect(convertOdds(3.00, 'UK'), '2/1'); // 2 to 1
        expect(convertOdds(1.50, 'UK'), '1/2'); // 1 to 2
      });

      test('should convert complex fractions', () {
        // 1.85 - 1 = 0.85 ≈ 17/20
        final result = convertOdds(1.85, 'UK');
        expect(result, contains('/'));
        
        // Vérifier que c'est une fraction valide
        final parts = result.split('/');
        expect(parts.length, 2);
        final num = int.parse(parts[0]);
        final den = int.parse(parts[1]);
        expect(num / den, closeTo(0.85, 0.05));
      });

      test('should handle odds close to 1', () {
        expect(convertOdds(1.10, 'UK'), '1/10');
        expect(convertOdds(1.20, 'UK'), '1/5');
      });
    });

    group('US format (American)', () {
      test('should convert odds >= 2.0 to positive American odds', () {
        expect(convertOdds(2.00, 'US'), '+100');
        expect(convertOdds(3.00, 'US'), '+200');
        expect(convertOdds(2.50, 'US'), '+150');
      });

      test('should convert odds < 2.0 to negative American odds', () {
        expect(convertOdds(1.50, 'US'), '-200');
        expect(convertOdds(1.85, 'US'), '-118');
        expect(convertOdds(1.10, 'US'), '-1000');
      });

      test('should handle edge case at 2.0', () {
        expect(convertOdds(2.00, 'US'), '+100');
      });
    });

    group('Edge cases', () {
      test('should handle very low odds', () {
        expect(convertOdds(1.01, 'FR'), '1.01');
        expect(convertOdds(1.01, 'UK'), contains('/'));
        expect(convertOdds(1.01, 'US').startsWith('-'), true);
      });

      test('should handle very high odds', () {
        expect(convertOdds(10.00, 'FR'), '10.00');
        expect(convertOdds(10.00, 'UK'), '9/1');
        expect(convertOdds(10.00, 'US'), '+900');
      });

      test('should default to FR format for unknown format', () {
        expect(convertOdds(1.85, 'UNKNOWN'), '1.85');
        expect(convertOdds(2.50, 'XYZ'), '2.50');
      });

      test('should be case insensitive', () {
        expect(convertOdds(2.00, 'fr'), '2.00');
        expect(convertOdds(2.00, 'uk'), '1/1');
        expect(convertOdds(2.00, 'us'), '+100');
        expect(convertOdds(2.00, 'Fr'), '2.00');
        expect(convertOdds(2.00, 'Uk'), '1/1');
        expect(convertOdds(2.00, 'Us'), '+100');
      });
    });

    group('Real world examples', () {
      test('Lakers vs Celtics typical odds', () {
        // Lakers favoris à 1.65
        expect(convertOdds(1.65, 'FR'), '1.65');
        expect(convertOdds(1.65, 'US'), '-154');
        
        // Celtics outsiders à 2.35
        expect(convertOdds(2.35, 'FR'), '2.35');
        expect(convertOdds(2.35, 'US'), '+135');
      });

      test('Close match odds', () {
        // Match serré
        expect(convertOdds(1.90, 'FR'), '1.90');
        expect(convertOdds(1.95, 'FR'), '1.95');
      });
    });
  });
}
