import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'HoopsBets'**
  String get title;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @noBetsSelected.
  ///
  /// In en, this message translates to:
  /// **'No bets selected'**
  String get noBetsSelected;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get totalAmount;

  /// No description provided for @reloadData.
  ///
  /// In en, this message translates to:
  /// **'Refresh my data'**
  String get reloadData;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUP.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUP;

  /// Displays the combined odd of selected bets
  ///
  /// In en, this message translates to:
  /// **'Total odds: {value}'**
  String combinedOdd(Object value);

  /// No description provided for @odd.
  ///
  /// In en, this message translates to:
  /// **'Odd'**
  String get odd;

  /// Indicates when the game starts
  ///
  /// In en, this message translates to:
  /// **'Starts at {startTime}'**
  String startsAt(Object startTime);

  /// Display the total payout
  ///
  /// In en, this message translates to:
  /// **'Payout: {amount}'**
  String payout(double amount);

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// Display the odd value and the start time of a bet
  ///
  /// In en, this message translates to:
  /// **'Odd: {odd} | Starts at: {startTime}'**
  String oddAndStartTime(double odd, String startTime);

  /// No description provided for @successfulBet.
  ///
  /// In en, this message translates to:
  /// **' Bet placed successfully ! ✅ '**
  String get successfulBet;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get passwordTooShort;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please type your password'**
  String get enterPassword;

  /// No description provided for @wrongEmail.
  ///
  /// In en, this message translates to:
  /// **'Wrong mail format'**
  String get wrongEmail;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please type your mail address'**
  String get enterEmail;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get wrongPassword;

  /// No description provided for @noAccountForTheseId.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get noAccountForTheseId;

  /// No description provided for @confirmPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get confirmPasswordError;

  /// No description provided for @mailAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get mailAlreadyUsed;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'This password is too weak'**
  String get weakPassword;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! ✅ '**
  String get accountCreated;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get userName;

  /// No description provided for @enterUserName.
  ///
  /// In en, this message translates to:
  /// **'Please type your username'**
  String get enterUserName;

  /// No description provided for @oddsFormat.
  ///
  /// In en, this message translates to:
  /// **'Choose your favorite odds format : '**
  String get oddsFormat;

  /// No description provided for @infosCotesCgu.
  ///
  /// In en, this message translates to:
  /// **'Odds & Terms Info'**
  String get infosCotesCgu;

  /// No description provided for @formatsDesCotes.
  ///
  /// In en, this message translates to:
  /// **'Odds formats:'**
  String get formatsDesCotes;

  /// No description provided for @formatsDesCotesDescription.
  ///
  /// In en, this message translates to:
  /// **'- FR: decimal odds (e.g., 2.5) → win = stake × odds\n- US: American odds (e.g., +150 / -200) → win depends on stake\n- UK: fractional odds (e.g., 5/2) → win = stake × (numerator / denominator)'**
  String get formatsDesCotesDescription;

  /// No description provided for @cgu.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions:'**
  String get cgu;

  /// No description provided for @cguDescription.
  ///
  /// In en, this message translates to:
  /// **'- You must be 18 years or older.\n- Bets are at your own risk.\n- Information provided must be accurate.\n- HoopsBets/Supabase is not responsible for financial losses.'**
  String get cguDescription;

  /// No description provided for @firstConnection.
  ///
  /// In en, this message translates to:
  /// **'First connection'**
  String get firstConnection;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmount;

  /// No description provided for @notEnoughPoints.
  ///
  /// In en, this message translates to:
  /// **'❌ Not enough points to place this bet'**
  String get notEnoughPoints;

  /// No description provided for @errorSendingBet.
  ///
  /// In en, this message translates to:
  /// **'❌ Error sending bet'**
  String get errorSendingBet;

  /// No description provided for @betDeleted.
  ///
  /// In en, this message translates to:
  /// **'❌ Bet deleted'**
  String get betDeleted;

  /// No description provided for @userNotConnected.
  ///
  /// In en, this message translates to:
  /// **'User not connected'**
  String get userNotConnected;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @myGraph.
  ///
  /// In en, this message translates to:
  /// **'My statistics'**
  String get myGraph;

  /// Displays the points added by the winning bets
  ///
  /// In en, this message translates to:
  /// **'{value} points earned !'**
  String pointsAdded(double value);

  /// No description provided for @myBets.
  ///
  /// In en, this message translates to:
  /// **'My bets'**
  String get myBets;

  /// No description provided for @dailyPoints.
  ///
  /// In en, this message translates to:
  /// **'Daily points'**
  String get dailyPoints;

  /// No description provided for @dailyPointsTaken.
  ///
  /// In en, this message translates to:
  /// **'Daily points already used'**
  String get dailyPointsTaken;

  /// No description provided for @leagues.
  ///
  /// In en, this message translates to:
  /// **'My leagues'**
  String get leagues;

  /// No description provided for @manageAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage my account'**
  String get manageAccount;

  /// No description provided for @rankings.
  ///
  /// In en, this message translates to:
  /// **'Rankings'**
  String get rankings;

  /// No description provided for @pointsEvolution.
  ///
  /// In en, this message translates to:
  /// **'Points evolution'**
  String get pointsEvolution;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get alreadyHaveAccount;

  /// No description provided for @leagueExists.
  ///
  /// In en, this message translates to:
  /// **'A league with this name already exists'**
  String get leagueExists;

  /// No description provided for @leagueCreated.
  ///
  /// In en, this message translates to:
  /// **'League created successfully! ✅'**
  String get leagueCreated;

  /// No description provided for @leagueJoined.
  ///
  /// In en, this message translates to:
  /// **'League joined successfully! ✅'**
  String get leagueJoined;

  /// No description provided for @myLeagues.
  ///
  /// In en, this message translates to:
  /// **'My leagues'**
  String get myLeagues;

  /// No description provided for @createLeague.
  ///
  /// In en, this message translates to:
  /// **'Create a league'**
  String get createLeague;

  /// No description provided for @leagueName.
  ///
  /// In en, this message translates to:
  /// **'League name'**
  String get leagueName;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @joinLeague.
  ///
  /// In en, this message translates to:
  /// **'Join a league'**
  String get joinLeague;

  /// No description provided for @enterLeagueName.
  ///
  /// In en, this message translates to:
  /// **'Please type the name of the league you want to join'**
  String get enterLeagueName;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// Displays the number of members in a league
  ///
  /// In en, this message translates to:
  /// **'Members: {count}'**
  String membersCount(int count);

  /// No description provided for @manageAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage my account'**
  String get manageAccountTitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameHint;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @oddsFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'Odds format'**
  String get oddsFormatLabel;

  /// No description provided for @oddsFormatFrench.
  ///
  /// In en, this message translates to:
  /// **'French (decimal)'**
  String get oddsFormatFrench;

  /// No description provided for @oddsFormatUS.
  ///
  /// In en, this message translates to:
  /// **'American'**
  String get oddsFormatUS;

  /// No description provided for @oddsFormatUK.
  ///
  /// In en, this message translates to:
  /// **'Fractional'**
  String get oddsFormatUK;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear local cache'**
  String get clearCache;

  /// No description provided for @loadingError.
  ///
  /// In en, this message translates to:
  /// **'Loading error: {error}'**
  String loadingError(Object error);

  /// No description provided for @updateError.
  ///
  /// In en, this message translates to:
  /// **'Update error: {error}'**
  String updateError(Object error);

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get updateSuccess;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache successfully cleared'**
  String get cacheCleared;

  /// No description provided for @yourBalance.
  ///
  /// In en, this message translates to:
  /// **'Your balance'**
  String get yourBalance;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @payoutText.
  ///
  /// In en, this message translates to:
  /// **'Payout'**
  String get payoutText;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordTitle;

  /// No description provided for @oldPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Old password'**
  String get oldPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmPasswordLabel;

  /// No description provided for @oldPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your old password'**
  String get oldPasswordEmpty;

  /// No description provided for @wrongOldPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect old password'**
  String get wrongOldPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdated;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorMessage(Object error);

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordButton;

  /// No description provided for @hoopsLeagueTitle.
  ///
  /// In en, this message translates to:
  /// **'HoopsLeague'**
  String get hoopsLeagueTitle;

  /// No description provided for @noMembersInLeague.
  ///
  /// In en, this message translates to:
  /// **'No members in this league'**
  String get noMembersInLeague;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownUser;

  /// No description provided for @pointsSuffix.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get pointsSuffix;

  /// No description provided for @leagueNotFound.
  ///
  /// In en, this message translates to:
  /// **'League not found'**
  String get leagueNotFound;

  /// No description provided for @slideToBet.
  ///
  /// In en, this message translates to:
  /// **'Slide to bet'**
  String get slideToBet;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to HoopsLeague'**
  String get welcomeBack;

  /// No description provided for @bugReport.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get bugReport;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get reportBug;

  /// No description provided for @describeBug.
  ///
  /// In en, this message translates to:
  /// **'Describe the bug'**
  String get describeBug;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @bugEmptyError.
  ///
  /// In en, this message translates to:
  /// **'The description cannot be empty'**
  String get bugEmptyError;

  /// No description provided for @connectionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connection successful'**
  String get connectionSuccess;

  /// No description provided for @suggestedLeagues.
  ///
  /// In en, this message translates to:
  /// **'Suggested leagues'**
  String get suggestedLeagues;

  /// No description provided for @leagueNotFoundWithName.
  ///
  /// In en, this message translates to:
  /// **'League not found'**
  String get leagueNotFoundWithName;

  /// No description provided for @requestAlreadySent.
  ///
  /// In en, this message translates to:
  /// **'Request already sent'**
  String get requestAlreadySent;

  /// No description provided for @requestSentPending.
  ///
  /// In en, this message translates to:
  /// **'Request sent, pending approval'**
  String get requestSentPending;

  /// No description provided for @errorSendingRequest.
  ///
  /// In en, this message translates to:
  /// **'Error sending request'**
  String get errorSendingRequest;

  /// No description provided for @userAcceptedInLeague.
  ///
  /// In en, this message translates to:
  /// **'has been accepted in the league'**
  String get userAcceptedInLeague;

  /// No description provided for @errorAcceptingUser.
  ///
  /// In en, this message translates to:
  /// **'Error accepting user'**
  String get errorAcceptingUser;

  /// No description provided for @userRejected.
  ///
  /// In en, this message translates to:
  /// **'has been rejected'**
  String get userRejected;

  /// No description provided for @errorRejectingUser.
  ///
  /// In en, this message translates to:
  /// **'Error rejecting user'**
  String get errorRejectingUser;

  /// No description provided for @leftLeague.
  ///
  /// In en, this message translates to:
  /// **'You left the league:'**
  String get leftLeague;

  /// No description provided for @errorLeavingLeague.
  ///
  /// In en, this message translates to:
  /// **'Error leaving league'**
  String get errorLeavingLeague;

  /// No description provided for @leaveLeague.
  ///
  /// In en, this message translates to:
  /// **'Leave league'**
  String get leaveLeague;

  /// No description provided for @leaveLeagueConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to leave this league?'**
  String get leaveLeagueConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending requests'**
  String get pendingRequests;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequests;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @leagueNotFoundPreview.
  ///
  /// In en, this message translates to:
  /// **'League not found'**
  String get leagueNotFoundPreview;

  /// No description provided for @alreadyMember.
  ///
  /// In en, this message translates to:
  /// **'Already a member'**
  String get alreadyMember;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
