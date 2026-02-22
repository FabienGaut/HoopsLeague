class OddsConverter {
  static String convert(double frOdd, String oddsFormat) {
    switch (oddsFormat.toUpperCase()) {
      case 'FR':
        // Use proper rounding: multiply by 100, round, then divide by 100
        return (((frOdd * 100).round()) / 100).toStringAsFixed(2);
      case 'UK':
        double fraction = frOdd - 1;
        return _toFraction(fraction);
      case 'US':
        // Handle edge case: odds of 1.0 would cause division by zero
        if (frOdd == 1.0) {
          return '±0'; // No profit/loss
        } else if (frOdd >= 2.0) {
          return '+${((frOdd - 1) * 100).round()}';
        } else {
          return (-100 / (frOdd - 1)).round().toString();
        }
      default:
        // Use proper rounding for default case too
        return ((frOdd * 100).round() / 100).toStringAsFixed(2);
    }
  }

  static String _toFraction(double value) {
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
}
