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
  String get noData => 'No data available';

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
  String get passwordTooShort => 'Minimum 6 characters';

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

  @override
  String get userName => 'Username';

  @override
  String get enterUserName => 'Please type your username';

  @override
  String get oddsFormat => 'Choose your favorite odds format : ';

  @override
  String get infosCotesCgu => 'Odds & Terms Info';

  @override
  String get formatsDesCotes => 'Odds formats:';

  @override
  String get formatsDesCotesDescription => '- FR: decimal odds (e.g., 2.5) → win = stake × odds\n- US: American odds (e.g., +150 / -200) → win depends on stake\n- UK: fractional odds (e.g., 5/2) → win = stake × (numerator / denominator)';

  @override
  String get cgu => 'Terms & Conditions:';

  @override
  String get cguDescription => '- You must be 18 years or older.\n- Bets are at your own risk.\n- Information provided must be accurate.\n- HoopsBets/Supabase is not responsible for financial losses.';

  @override
  String get firstConnection => 'First connection';

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String get notEnoughPoints => '❌ Not enough points to place this bet';

  @override
  String get errorSendingBet => '❌ Error sending bet';

  @override
  String get betDeleted => '❌ Bet deleted';

  @override
  String get userNotConnected => 'User not connected';

  @override
  String get save => 'Save';

  @override
  String get myGraph => 'My statistics';

  @override
  String pointsAdded(double value) {
    return '$value points earned !';
  }

  @override
  String get myBets => 'My bets';

  @override
  String get dailyPoints => 'Daily points';

  @override
  String get dailyPointsTaken => 'Daily points already used';

  @override
  String get leagues => 'My leagues';

  @override
  String get manageAccount => 'Manage my account';

  @override
  String get rankings => 'Rankings';

  @override
  String get pointsEvolution => 'Points evolution';

  @override
  String get alreadyHaveAccount => 'Sign in';

  @override
  String get leagueExists => 'A league with this name already exists';

  @override
  String get leagueCreated => 'League created successfully! ✅';

  @override
  String get leagueJoined => 'League joined successfully! ✅';

  @override
  String get myLeagues => 'My leagues';

  @override
  String get createLeague => 'Create a league';

  @override
  String get leagueName => 'League name';

  @override
  String get create => 'Create';

  @override
  String get joinLeague => 'Join a league';

  @override
  String get enterLeagueName => 'Please type the name of the league you want to join';

  @override
  String get join => 'Join';

  @override
  String membersCount(int count) {
    return 'Members: $count';
  }

  @override
  String get manageAccountTitle => 'Manage my account';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'Username';

  @override
  String get saveButton => 'Save';

  @override
  String get languageLabel => 'Language';

  @override
  String get french => 'French';

  @override
  String get english => 'English';

  @override
  String get oddsFormatLabel => 'Odds format';

  @override
  String get oddsFormatFrench => 'French (decimal)';

  @override
  String get oddsFormatUS => 'American';

  @override
  String get oddsFormatUK => 'Fractional';

  @override
  String get changePassword => 'Change password';

  @override
  String get clearCache => 'Clear local cache';

  @override
  String loadingError(Object error) {
    return 'Loading error: $error';
  }

  @override
  String updateError(Object error) {
    return 'Update error: $error';
  }

  @override
  String get updateSuccess => 'Changes saved';

  @override
  String get cacheCleared => 'Cache successfully cleared';

  @override
  String get yourBalance => 'Your balance';

  @override
  String get amount => 'Amount';

  @override
  String get payoutText => 'Payout';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get oldPasswordLabel => 'Old password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm new password';

  @override
  String get oldPasswordEmpty => 'Please enter your old password';

  @override
  String get wrongOldPassword => 'Incorrect old password';

  @override
  String get passwordsDoNotMatch => 'New passwords do not match';

  @override
  String get passwordUpdated => 'Password updated successfully';

  @override
  String errorMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String get changePasswordButton => 'Change password';

  @override
  String get hoopsLeagueTitle => 'HoopsLeague';

  @override
  String get noMembersInLeague => 'No members in this league';

  @override
  String get unknownUser => 'Unknown';

  @override
  String get pointsSuffix => 'pts';

  @override
  String get leagueNotFound => 'League not found';

  @override
  String get slideToBet => 'Slide to bet';

  @override
  String get welcomeBack => 'Welcome back to HoopsLeague';

  @override
  String get bugReport => 'Report a bug';

  @override
  String get reportBug => 'Report a bug';

  @override
  String get describeBug => 'Describe the bug';

  @override
  String get send => 'Send';

  @override
  String get bugEmptyError => 'The description cannot be empty';
}
