// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'HoopsLeague';

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
  String get email => 'Email';

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
  String get cguDescription => '';

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
  String get manageAccount => 'Settings';

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
  String get memberCountSingular => '1 member';

  @override
  String memberCountPlural(int count) {
    return '$count members';
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

  @override
  String get connectionSuccess => 'Connection successful';

  @override
  String get suggestedLeagues => 'Suggested leagues';

  @override
  String get leagueNotFoundWithName => 'League not found';

  @override
  String get requestAlreadySent => 'Request already sent';

  @override
  String get requestSentPending => 'Request sent, pending approval';

  @override
  String get errorSendingRequest => 'Error sending request';

  @override
  String get userAcceptedInLeague => 'has been accepted in the league';

  @override
  String get errorAcceptingUser => 'Error accepting user';

  @override
  String get userRejected => 'has been rejected';

  @override
  String get errorRejectingUser => 'Error rejecting user';

  @override
  String get leftLeague => 'You left the league:';

  @override
  String get errorLeavingLeague => 'Error leaving league';

  @override
  String get leaveLeague => 'Leave league';

  @override
  String get leaveLeagueConfirm => 'Do you really want to leave this league?';

  @override
  String get cancel => 'Cancel';

  @override
  String get leave => 'Leave';

  @override
  String get pendingRequests => 'Pending requests';

  @override
  String get noPendingRequests => 'No pending requests';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get leagueNotFoundPreview => 'League not found';

  @override
  String get alreadyMember => 'Already a member';

  @override
  String get quit => 'Quit';

  @override
  String get allRightsReserved => 'All rights reserved.';

  @override
  String get noGamesToday => 'No games played today';

  @override
  String get securityError => 'Security error';

  @override
  String get unauthorizedAccess => 'Unauthorized access';

  @override
  String get sessionExpired => 'Session expired. Please log in again.';

  @override
  String get uidError => 'UID Error';

  @override
  String get userLoadingError => 'User loading error';

  @override
  String get multipleBets => 'Multiple Bets';

  @override
  String get singleBet => 'Single Bet';

  @override
  String get joinedLeague => 'You joined the league';

  @override
  String get alreadyInPending => 'Request already sent';

  @override
  String get requestSent => 'Request sent';

  @override
  String get nbaDisclaimer => 'This application is independent and has no official connection with the NBA.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirm => 'Are you sure you want to delete your account? This action is irreversible.';

  @override
  String get accountDeleted => 'Account successfully deleted';

  @override
  String get errorDeletingAccount => 'Error deleting account';

  @override
  String get howToUse => 'How to use the app';

  @override
  String get swipeToSelectTeam => 'Swipe left or right to select the winning team:';

  @override
  String get errorDeletingAuthUser => 'Error deleting authentication account';

  @override
  String get errorDeletingUserData => 'Error cleaning up user data';

  @override
  String get captchaRequired => 'Please complete the CAPTCHA verification';

  @override
  String get captchaError => 'CAPTCHA verification failed. Please try again.';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get legalNotice => 'Legal Notice';

  @override
  String get emailConfirmationTitle => 'Check your email';

  @override
  String emailConfirmationMessage(String email) {
    return 'A confirmation link has been sent to $email. Please click on the link to activate your account.';
  }

  @override
  String get backToSignIn => 'Back to Sign In';

  @override
  String get emailConfirmationButton => 'Got it';

  @override
  String get oddsDisclaimer => 'Odds are provided for informational purposes only and do not constitute an incentive to bet.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get resetPasswordTitle => 'Reset your password';

  @override
  String get resetPasswordInstructions => 'Enter the email address associated with your account. You will receive a link to reset your password.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get resetEmailSent => 'Password reset email sent! Please check your inbox.';

  @override
  String get resetEmailError => 'Error sending reset email. Please verify your email address.';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get resetPasswordPageTitle => 'Set new password';

  @override
  String get resetPasswordPageInstructions => 'Enter your new password below.';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get setNewPassword => 'Set password';

  @override
  String get passwordResetSuccess => 'Password successfully reset! You can now sign in with your new password.';

  @override
  String get passwordResetError => 'Error resetting password. The link may have expired.';

  @override
  String get invalidResetLink => 'Invalid or expired reset link.';

  @override
  String get teamStatistics => 'Team Statistics';

  @override
  String get injuredPlayers => 'Injured Players';

  @override
  String get noInjuries => 'No injuries reported';

  @override
  String get lastGames => 'Last Games';

  @override
  String get loading => 'Loading...';

  @override
  String get errorLoadingStats => 'Error loading statistics';

  @override
  String get tapToFlipBack => 'Tap to flip back';

  @override
  String get win => 'W';

  @override
  String get loss => 'L';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get tutorialStatsTitle => 'Tap to View Stats';

  @override
  String get tutorialStatsDesc => 'Tap on any game card to flip it and see detailed team statistics, player performance, and injury reports.';

  @override
  String get tutorialSwipeTitle => 'Swipe to Bet';

  @override
  String get tutorialSwipeDesc => 'Swipe right to bet on the home team, or swipe left to bet on the away team. Your selections will be added to your betting cart.';

  @override
  String get tutorialOddsTitle => 'Understanding Odds';

  @override
  String get tutorialOddsDesc => 'Odds represent the potential return on your bet. Higher odds mean higher risk but bigger rewards. You can place single bets or combine multiple bets for higher returns. Remember: the higher the odds, the less likely it is to win.';

  @override
  String get tutorialMenuTitle => 'Menu & Cart';

  @override
  String get tutorialMenuDesc => 'Access the menu (top left) to view your profile, betting history, and account settings. Your betting cart (bottom right) shows your current selections.';

  @override
  String get tutorialDailyPointsTitle => 'Daily Points';

  @override
  String get tutorialDailyPointsDesc => 'Claim 10 free points every day! Go to the menu and tap \'Daily Points\' to collect them. Use these points to place bets and grow your balance.';

  @override
  String get tutorialLeaguesTitle => 'Join Leagues';

  @override
  String get tutorialLeaguesDesc => 'Create or join leagues with your friends! Compete on a leaderboard based on your points. Check the rankings to see who\'s the best predictor.';

  @override
  String get gameAlreadyStarted => '⚠️ One or more games have already started. You cannot bet on games in progress.';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutConfirmation => 'Do you really want to log out?';

  @override
  String get logoutSuccess => 'You have been successfully logged out';

  @override
  String logoutError(Object error) {
    return 'Error during logout: $error';
  }

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountWarning => '⚠️ WARNING: This action is irreversible!\n\nBy deleting your account, you will lose:\n• All your points\n• All your bets\n• Your history\n• Your statistics\n• Your league memberships\n\nAre you sure you want to continue?';

  @override
  String get areYouSure => 'Are you really sure?';

  @override
  String get deleteAccountFinalWarning => 'This is your last chance!\n\nAll your data will be permanently deleted and you won\'t be able to recover it.\n\nDo you really want to permanently delete your account?';

  @override
  String get deleteAccountPermanently => 'Delete permanently';

  @override
  String get accountDeletedSuccess => 'Your account has been successfully deleted';

  @override
  String deleteAccountError(Object error) {
    return 'Error deleting account: $error';
  }

  @override
  String get about => 'About';

  @override
  String get appDescription => 'HoopsLeague is a virtual sports betting app for NBA games. Bet with virtual points, create leagues with your friends, and climb the rankings!';

  @override
  String get legalInformation => 'Legal Information';

  @override
  String get credits => 'Credits';

  @override
  String get twemojiCredit => 'Emojis used in this app are provided by Twemoji, created by Twitter. Licensed under CC-BY 4.0.';

  @override
  String get notoEmojiCredit => 'Color emoji font provided by Google. Licensed under Open Font License.';

  @override
  String get flutterCredit => 'App developed with Flutter, Google\'s UI framework for building natively compiled applications.';

  @override
  String get combinedBet => 'Combined bet';

  @override
  String get perBet => 'per bet';

  @override
  String get samePasswordError => 'The new password must be different from the current one';

  @override
  String get previewGames => 'See available games';

  @override
  String get authRequiredTitle => 'Sign in required';

  @override
  String get authRequiredMessage => 'Create an account or sign in to place bets and track your predictions!';

  @override
  String get emojiLegendTitle => 'Situational Emojis';

  @override
  String get emojiLegendSubtitle => 'Meaning of emojis displayed on games';

  @override
  String get emojiTank => 'Last in conference (tank)';

  @override
  String get emojiBomb => '10 consecutive wins';

  @override
  String get emojiCold => '5 consecutive losses';

  @override
  String get emojiFire => '5 consecutive wins';

  @override
  String get emojiGold => '1st in conference';

  @override
  String get emojiSilver => '2nd in conference';

  @override
  String get emojiBronze => '3rd in conference';

  @override
  String get emojiHospital => '5+ injured players';

  @override
  String get emojiDefault => 'Default team emoji';

  @override
  String get playoffBracket => 'Playoff Bracket';

  @override
  String get playoffBracketSubtitle => 'Pick your winners from Play-In to the Finals!';

  @override
  String get playIn => 'Play-In';

  @override
  String get firstRound => '1st Round';

  @override
  String get confSemis => 'Conf. Semis';

  @override
  String get confFinals => 'Conf. Finals';

  @override
  String get finals => 'Finals';

  @override
  String get champion => 'Champion';

  @override
  String get eastConference => 'East';

  @override
  String get westConference => 'West';

  @override
  String get selectWinner => 'Tap to select a winner';

  @override
  String get bracketReset => 'Bracket reset';

  @override
  String get playoffEvent => 'Playoffs';

  @override
  String get pickYourChampion => 'Pick your champion!';

  @override
  String get saveBracket => 'Save';

  @override
  String get bracketSaved => 'Bracket saved!';

  @override
  String get validateBracket => 'Validate bracket';

  @override
  String get bracketValidated => 'Bracket validated! It is now locked.';

  @override
  String get bracketAlreadyValidated => 'This bracket is already validated and cannot be modified.';

  @override
  String get bracketIncomplete => 'Complete your bracket before validating (pick a champion).';

  @override
  String get compareBrackets => 'Compare brackets';

  @override
  String get leagueBrackets => 'League Brackets';

  @override
  String get noBracketsYet => 'No validated brackets yet in this league.';

  @override
  String get selectLeague => 'Select a league';

  @override
  String get validatedOn => 'Validated on';

  @override
  String get bracketLocked => 'Locked';

  @override
  String get bracketDraft => 'Draft';
}
