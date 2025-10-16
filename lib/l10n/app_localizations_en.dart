// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'HoopsBets';

  @override
  String get noData => 'No data';

  @override
  String get noBetsSelected => 'No bets selected';

  @override
  String get totalAmount => 'Total amount';

  @override
  String get reloadData => 'Refresh my data';

  @override
  String get logout => 'Logout';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUP => 'Sign up';

  @override
  String combinedOdd(Object value) {
    return 'Total odds: $value';
  }

  @override
  String get odd => 'Odd';

  @override
  String startsAt(Object startTime) {
    return 'Starts at $startTime';
  }

  @override
  String payout(double amount) {
    return 'Payout: $amount';
  }

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm your password';

  @override
  String get createAccount => 'Create an account';

  @override
  String oddAndStartTime(double odd, String startTime) {
    return 'Odd: $odd | Starts at: $startTime';
  }

  @override
  String get successfulBet => ' Bet placed successfully ! ✅ ';

  @override
  String get passwordTooShort =>
      'Password too short! Must be at least 6 characters.';

  @override
  String get enterPassword => 'Please type your password';

  @override
  String get wrongEmail => 'Wrong mail format';

  @override
  String get enterEmail => 'Please type your mail address';

  @override
  String get wrongPassword => 'Wrong password';

  @override
  String get noAccountForTheseId => 'Incorrect email or password';

  @override
  String get confirmPasswordError => 'Passwords do not match';

  @override
  String get mailAlreadyUsed => 'This email is already registered';

  @override
  String get weakPassword => 'This password is too weak';

  @override
  String get accountCreated => 'Account created successfully! ✅ ';
}
