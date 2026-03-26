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
  /// **'HoopsLeague'**
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

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

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
  /// **''**
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
  /// **'Settings'**
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

  /// No description provided for @memberCountSingular.
  ///
  /// In en, this message translates to:
  /// **'1 member'**
  String get memberCountSingular;

  /// No description provided for @memberCountPlural.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String memberCountPlural(int count);

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

  /// No description provided for @allRightsReserved.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved.'**
  String get allRightsReserved;

  /// No description provided for @noGamesToday.
  ///
  /// In en, this message translates to:
  /// **'No games played today'**
  String get noGamesToday;

  /// No description provided for @securityError.
  ///
  /// In en, this message translates to:
  /// **'Security error'**
  String get securityError;

  /// No description provided for @unauthorizedAccess.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized access'**
  String get unauthorizedAccess;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get sessionExpired;

  /// No description provided for @uidError.
  ///
  /// In en, this message translates to:
  /// **'UID Error'**
  String get uidError;

  /// No description provided for @userLoadingError.
  ///
  /// In en, this message translates to:
  /// **'User loading error'**
  String get userLoadingError;

  /// No description provided for @multipleBets.
  ///
  /// In en, this message translates to:
  /// **'Multiple Bets'**
  String get multipleBets;

  /// No description provided for @singleBet.
  ///
  /// In en, this message translates to:
  /// **'Single Bet'**
  String get singleBet;

  /// No description provided for @joinedLeague.
  ///
  /// In en, this message translates to:
  /// **'You joined the league'**
  String get joinedLeague;

  /// No description provided for @alreadyInPending.
  ///
  /// In en, this message translates to:
  /// **'Request already sent'**
  String get alreadyInPending;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get requestSent;

  /// No description provided for @nbaDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This application is independent and has no official connection with the NBA.'**
  String get nbaDisclaimer;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action is irreversible.'**
  String get deleteAccountConfirm;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account successfully deleted'**
  String get accountDeleted;

  /// No description provided for @errorDeletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Error deleting account'**
  String get errorDeletingAccount;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to use the app'**
  String get howToUse;

  /// No description provided for @swipeToSelectTeam.
  ///
  /// In en, this message translates to:
  /// **'Swipe left or right to select the winning team:'**
  String get swipeToSelectTeam;

  /// No description provided for @errorDeletingAuthUser.
  ///
  /// In en, this message translates to:
  /// **'Error deleting authentication account'**
  String get errorDeletingAuthUser;

  /// No description provided for @errorDeletingUserData.
  ///
  /// In en, this message translates to:
  /// **'Error cleaning up user data'**
  String get errorDeletingUserData;

  /// No description provided for @captchaRequired.
  ///
  /// In en, this message translates to:
  /// **'Please complete the CAPTCHA verification'**
  String get captchaRequired;

  /// No description provided for @captchaError.
  ///
  /// In en, this message translates to:
  /// **'CAPTCHA verification failed. Please try again.'**
  String get captchaError;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @legalNotice.
  ///
  /// In en, this message translates to:
  /// **'Legal Notice'**
  String get legalNotice;

  /// No description provided for @emailConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get emailConfirmationTitle;

  /// No description provided for @emailConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'A confirmation link has been sent to {email}. Please click on the link to activate your account.'**
  String emailConfirmationMessage(String email);

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @emailConfirmationButton.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get emailConfirmationButton;

  /// No description provided for @oddsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Odds are provided for informational purposes only and do not constitute an incentive to bet.'**
  String get oddsDisclaimer;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter the email address associated with your account. You will receive a link to reset your password.'**
  String get resetPasswordInstructions;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent! Please check your inbox.'**
  String get resetEmailSent;

  /// No description provided for @resetEmailError.
  ///
  /// In en, this message translates to:
  /// **'Error sending reset email. Please verify your email address.'**
  String get resetEmailError;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @resetPasswordPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get resetPasswordPageTitle;

  /// No description provided for @resetPasswordPageInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password below.'**
  String get resetPasswordPageInstructions;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set password'**
  String get setNewPassword;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password successfully reset! You can now sign in with your new password.'**
  String get passwordResetSuccess;

  /// No description provided for @passwordResetError.
  ///
  /// In en, this message translates to:
  /// **'Error resetting password. The link may have expired.'**
  String get passwordResetError;

  /// No description provided for @invalidResetLink.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired reset link.'**
  String get invalidResetLink;

  /// No description provided for @teamStatistics.
  ///
  /// In en, this message translates to:
  /// **'Team Statistics'**
  String get teamStatistics;

  /// No description provided for @injuredPlayers.
  ///
  /// In en, this message translates to:
  /// **'Injured Players'**
  String get injuredPlayers;

  /// No description provided for @noInjuries.
  ///
  /// In en, this message translates to:
  /// **'No injuries reported'**
  String get noInjuries;

  /// No description provided for @lastGames.
  ///
  /// In en, this message translates to:
  /// **'Last Games'**
  String get lastGames;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorLoadingStats.
  ///
  /// In en, this message translates to:
  /// **'Error loading statistics'**
  String get errorLoadingStats;

  /// No description provided for @tapToFlipBack.
  ///
  /// In en, this message translates to:
  /// **'Tap to flip back'**
  String get tapToFlipBack;

  /// No description provided for @win.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get win;

  /// No description provided for @loss.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get loss;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @tutorialStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to View Stats'**
  String get tutorialStatsTitle;

  /// No description provided for @tutorialStatsDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap on any game card to flip it and see detailed team statistics, player performance, and injury reports.'**
  String get tutorialStatsDesc;

  /// No description provided for @tutorialSwipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Swipe to Bet'**
  String get tutorialSwipeTitle;

  /// No description provided for @tutorialSwipeDesc.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to bet on the home team, or swipe left to bet on the away team. Your selections will be added to your betting cart.'**
  String get tutorialSwipeDesc;

  /// No description provided for @tutorialOddsTitle.
  ///
  /// In en, this message translates to:
  /// **'Understanding Odds'**
  String get tutorialOddsTitle;

  /// No description provided for @tutorialOddsDesc.
  ///
  /// In en, this message translates to:
  /// **'Odds represent the potential return on your bet. Higher odds mean higher risk but bigger rewards. You can place single bets or combine multiple bets for higher returns. Remember: the higher the odds, the less likely it is to win.'**
  String get tutorialOddsDesc;

  /// No description provided for @tutorialMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu & Cart'**
  String get tutorialMenuTitle;

  /// No description provided for @tutorialMenuDesc.
  ///
  /// In en, this message translates to:
  /// **'Access the menu (top left) to view your profile, betting history, and account settings. Your betting cart (bottom right) shows your current selections.'**
  String get tutorialMenuDesc;

  /// No description provided for @tutorialDailyPointsTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Points'**
  String get tutorialDailyPointsTitle;

  /// No description provided for @tutorialDailyPointsDesc.
  ///
  /// In en, this message translates to:
  /// **'Claim 10 free points every day! Go to the menu and tap \'Daily Points\' to collect them. Use these points to place bets and grow your balance.'**
  String get tutorialDailyPointsDesc;

  /// No description provided for @tutorialLeaguesTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Leagues'**
  String get tutorialLeaguesTitle;

  /// No description provided for @tutorialLeaguesDesc.
  ///
  /// In en, this message translates to:
  /// **'Create or join leagues with your friends! Compete on a leaderboard based on your points. Check the rankings to see who\'s the best predictor.'**
  String get tutorialLeaguesDesc;

  /// No description provided for @gameAlreadyStarted.
  ///
  /// In en, this message translates to:
  /// **'⚠️ One or more games have already started. You cannot bet on games in progress.'**
  String get gameAlreadyStarted;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'You have been successfully logged out'**
  String get logoutSuccess;

  /// No description provided for @logoutError.
  ///
  /// In en, this message translates to:
  /// **'Error during logout: {error}'**
  String logoutError(Object error);

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ WARNING: This action is irreversible!\n\nBy deleting your account, you will lose:\n• All your points\n• All your bets\n• Your history\n• Your statistics\n• Your league memberships\n\nAre you sure you want to continue?'**
  String get deleteAccountWarning;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you really sure?'**
  String get areYouSure;

  /// No description provided for @deleteAccountFinalWarning.
  ///
  /// In en, this message translates to:
  /// **'This is your last chance!\n\nAll your data will be permanently deleted and you won\'t be able to recover it.\n\nDo you really want to permanently delete your account?'**
  String get deleteAccountFinalWarning;

  /// No description provided for @deleteAccountPermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deleteAccountPermanently;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully deleted'**
  String get accountDeletedSuccess;

  /// No description provided for @deleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting account: {error}'**
  String deleteAccountError(Object error);

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'HoopsLeague is a virtual sports betting app for NBA games. Bet with virtual points, create leagues with your friends, and climb the rankings!'**
  String get appDescription;

  /// No description provided for @legalInformation.
  ///
  /// In en, this message translates to:
  /// **'Legal Information'**
  String get legalInformation;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @twemojiCredit.
  ///
  /// In en, this message translates to:
  /// **'Emojis used in this app are provided by Twemoji, created by Twitter. Licensed under CC-BY 4.0.'**
  String get twemojiCredit;

  /// No description provided for @notoEmojiCredit.
  ///
  /// In en, this message translates to:
  /// **'Color emoji font provided by Google. Licensed under Open Font License.'**
  String get notoEmojiCredit;

  /// No description provided for @flutterCredit.
  ///
  /// In en, this message translates to:
  /// **'App developed with Flutter, Google\'s UI framework for building natively compiled applications.'**
  String get flutterCredit;

  /// No description provided for @combinedBet.
  ///
  /// In en, this message translates to:
  /// **'Combined bet'**
  String get combinedBet;

  /// No description provided for @perBet.
  ///
  /// In en, this message translates to:
  /// **'per bet'**
  String get perBet;

  /// No description provided for @samePasswordError.
  ///
  /// In en, this message translates to:
  /// **'The new password must be different from the current one'**
  String get samePasswordError;

  /// No description provided for @previewGames.
  ///
  /// In en, this message translates to:
  /// **'See available games'**
  String get previewGames;

  /// No description provided for @authRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get authRequiredTitle;

  /// No description provided for @authRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Create an account or sign in to place bets and track your predictions!'**
  String get authRequiredMessage;

  /// No description provided for @emojiLegendTitle.
  ///
  /// In en, this message translates to:
  /// **'Situational Emojis'**
  String get emojiLegendTitle;

  /// No description provided for @emojiLegendSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Meaning of emojis displayed on games'**
  String get emojiLegendSubtitle;

  /// No description provided for @emojiTank.
  ///
  /// In en, this message translates to:
  /// **'Last in conference (tank)'**
  String get emojiTank;

  /// No description provided for @emojiBomb.
  ///
  /// In en, this message translates to:
  /// **'10 consecutive wins'**
  String get emojiBomb;

  /// No description provided for @emojiCold.
  ///
  /// In en, this message translates to:
  /// **'5 consecutive losses'**
  String get emojiCold;

  /// No description provided for @emojiFire.
  ///
  /// In en, this message translates to:
  /// **'5 consecutive wins'**
  String get emojiFire;

  /// No description provided for @emojiGold.
  ///
  /// In en, this message translates to:
  /// **'1st in conference'**
  String get emojiGold;

  /// No description provided for @emojiSilver.
  ///
  /// In en, this message translates to:
  /// **'2nd in conference'**
  String get emojiSilver;

  /// No description provided for @emojiBronze.
  ///
  /// In en, this message translates to:
  /// **'3rd in conference'**
  String get emojiBronze;

  /// No description provided for @emojiHospital.
  ///
  /// In en, this message translates to:
  /// **'5+ injured players'**
  String get emojiHospital;

  /// No description provided for @emojiDefault.
  ///
  /// In en, this message translates to:
  /// **'Default team emoji'**
  String get emojiDefault;

  /// No description provided for @playoffBracket.
  ///
  /// In en, this message translates to:
  /// **'Playoff Bracket'**
  String get playoffBracket;

  /// No description provided for @playoffBracketSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your winners from Play-In to the Finals!'**
  String get playoffBracketSubtitle;

  /// No description provided for @playIn.
  ///
  /// In en, this message translates to:
  /// **'Play-In'**
  String get playIn;

  /// No description provided for @firstRound.
  ///
  /// In en, this message translates to:
  /// **'1st Round'**
  String get firstRound;

  /// No description provided for @confSemis.
  ///
  /// In en, this message translates to:
  /// **'Conf. Semis'**
  String get confSemis;

  /// No description provided for @confFinals.
  ///
  /// In en, this message translates to:
  /// **'Conf. Finals'**
  String get confFinals;

  /// No description provided for @finals.
  ///
  /// In en, this message translates to:
  /// **'Finals'**
  String get finals;

  /// No description provided for @champion.
  ///
  /// In en, this message translates to:
  /// **'Champion'**
  String get champion;

  /// No description provided for @eastConference.
  ///
  /// In en, this message translates to:
  /// **'East'**
  String get eastConference;

  /// No description provided for @westConference.
  ///
  /// In en, this message translates to:
  /// **'West'**
  String get westConference;

  /// No description provided for @selectWinner.
  ///
  /// In en, this message translates to:
  /// **'Tap to select a winner'**
  String get selectWinner;

  /// No description provided for @bracketReset.
  ///
  /// In en, this message translates to:
  /// **'Bracket reset'**
  String get bracketReset;

  /// No description provided for @playoffEvent.
  ///
  /// In en, this message translates to:
  /// **'Playoffs'**
  String get playoffEvent;

  /// No description provided for @pickYourChampion.
  ///
  /// In en, this message translates to:
  /// **'Pick your champion!'**
  String get pickYourChampion;

  /// No description provided for @saveBracket.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveBracket;

  /// No description provided for @bracketSaved.
  ///
  /// In en, this message translates to:
  /// **'Bracket saved!'**
  String get bracketSaved;

  /// No description provided for @validateBracket.
  ///
  /// In en, this message translates to:
  /// **'Validate bracket'**
  String get validateBracket;

  /// No description provided for @bracketValidated.
  ///
  /// In en, this message translates to:
  /// **'Bracket validated! It is now locked.'**
  String get bracketValidated;

  /// No description provided for @bracketAlreadyValidated.
  ///
  /// In en, this message translates to:
  /// **'This bracket is already validated and cannot be modified.'**
  String get bracketAlreadyValidated;

  /// No description provided for @bracketIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Complete your bracket before validating (pick a champion).'**
  String get bracketIncomplete;

  /// No description provided for @compareBrackets.
  ///
  /// In en, this message translates to:
  /// **'Compare brackets'**
  String get compareBrackets;

  /// No description provided for @leagueBrackets.
  ///
  /// In en, this message translates to:
  /// **'League Brackets'**
  String get leagueBrackets;

  /// No description provided for @noBracketsYet.
  ///
  /// In en, this message translates to:
  /// **'No validated brackets yet in this league.'**
  String get noBracketsYet;

  /// No description provided for @selectLeague.
  ///
  /// In en, this message translates to:
  /// **'Select a league'**
  String get selectLeague;

  /// No description provided for @validatedOn.
  ///
  /// In en, this message translates to:
  /// **'Validated on'**
  String get validatedOn;

  /// No description provided for @bracketLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get bracketLocked;

  /// No description provided for @bracketDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get bracketDraft;
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
