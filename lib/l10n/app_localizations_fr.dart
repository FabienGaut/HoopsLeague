// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get title => 'HoopsLeague';

  @override
  String get noData => 'Aucune donnée disponible';

  @override
  String get noBetsSelected => 'Aucun pari';

  @override
  String get totalAmount => 'Montant total';

  @override
  String get reloadData => 'Rafraîchir mes données';

  @override
  String get logout => 'Déconnexion';

  @override
  String get signIn => 'Connexion';

  @override
  String get signUP => 'Créer un compte';

  @override
  String combinedOdd(Object value) {
    return 'Cote combinée : $value';
  }

  @override
  String get odd => 'Cote';

  @override
  String startsAt(Object startTime) {
    return 'Commence à $startTime';
  }

  @override
  String payout(double amount) {
    return 'Gains : $amount';
  }

  @override
  String get password => 'Mot de passe';

  @override
  String get email => 'Email';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String oddAndStartTime(double odd, String startTime) {
    return 'Cote: $odd | Début du match : $startTime';
  }

  @override
  String get successfulBet => ' Pari enregistré ✅ ';

  @override
  String get passwordTooShort => 'Minimum 6 caractères';

  @override
  String get enterPassword => 'Entrez votre mot de passe';

  @override
  String get wrongEmail => 'Email incorrect';

  @override
  String get enterEmail => 'Entrez votre email';

  @override
  String get wrongPassword => 'Mauvais mot de passe';

  @override
  String get noAccountForTheseId => 'Email ou mot de passe incorrect';

  @override
  String get confirmPasswordError => 'Les mots de passe ne sont pas les mêmes !';

  @override
  String get mailAlreadyUsed => 'Cette adresse email est déjà utilisée';

  @override
  String get weakPassword => 'Le mot de passe est trop faible';

  @override
  String get accountCreated => 'Votre compte a été créé avec succès';

  @override
  String get userName => 'Nom d\'utilisateur';

  @override
  String get enterUserName => 'Entrez votre nom d\'utilisateur';

  @override
  String get oddsFormat => 'Choisissez votre format de cote préféré :';

  @override
  String get infosCotesCgu => 'Infos cotes & CGU';

  @override
  String get formatsDesCotes => 'Formats des cotes :';

  @override
  String get formatsDesCotesDescription => '- FR : cotes décimales (ex : 2.5) → gain = mise × cote\\n- US : cotes américaines (ex : +150 / -200) → gain selon montant mis\\n- UK : cotes fractionnaires (ex : 5/2) → gain = mise × (numérateur / dénominateur)';

  @override
  String get cgu => 'Conditions générales (CGU) :';

  @override
  String get cguDescription => '';

  @override
  String get firstConnection => 'Première connexion';

  @override
  String get invalidAmount => 'Montant invalide';

  @override
  String get notEnoughPoints => '❌ Solde insuffisant pour ce pari.';

  @override
  String get errorSendingBet => '❌ Erreur lors de l\'envoi du pari';

  @override
  String get betDeleted => '❌ Pari supprimé';

  @override
  String get userNotConnected => 'Utilisateur non connecté';

  @override
  String get save => 'Enregistrer';

  @override
  String get myGraph => 'Mes statistiques';

  @override
  String pointsAdded(double value) {
    return '$value points gagnés !';
  }

  @override
  String get myBets => 'Mes paris';

  @override
  String get dailyPoints => 'Bonus quotidien';

  @override
  String get dailyPointsTaken => 'Bonus déjà utilisé';

  @override
  String get leagues => 'Mes ligues';

  @override
  String get manageAccount => 'Paramètres';

  @override
  String get rankings => 'Classement';

  @override
  String get pointsEvolution => 'Évolution des points';

  @override
  String get alreadyHaveAccount => 'Se connecter';

  @override
  String get leagueExists => 'Une ligue avec ce nom existe déjà !';

  @override
  String get leagueCreated => 'La ligue a été créée ! ✅';

  @override
  String get leagueJoined => 'Vous avez rejoint la ligue ! ✅';

  @override
  String get myLeagues => 'Mes ligues';

  @override
  String get createLeague => 'Créer une ligue';

  @override
  String get leagueName => 'Nom de la ligue';

  @override
  String get create => 'Créer';

  @override
  String get joinLeague => 'Rejoindre une ligue';

  @override
  String get enterLeagueName => 'Entrez le nom de la ligue';

  @override
  String get join => 'Rejoindre';

  @override
  String membersCount(int count) {
    return 'Membres: $count';
  }

  @override
  String get memberCountSingular => '1 membre';

  @override
  String memberCountPlural(int count) {
    return '$count membres';
  }

  @override
  String get manageAccountTitle => 'Gérer mon compte';

  @override
  String get usernameLabel => 'Nom d\'utilisateur';

  @override
  String get usernameHint => 'Nom d\'utilisateur';

  @override
  String get saveButton => 'Sauvegarder';

  @override
  String get languageLabel => 'Langue';

  @override
  String get french => 'Français';

  @override
  String get english => 'English';

  @override
  String get oddsFormatLabel => 'Format des cotes';

  @override
  String get oddsFormatFrench => 'Français (décimal)';

  @override
  String get oddsFormatUS => 'Américain';

  @override
  String get oddsFormatUK => 'Fractionnel';

  @override
  String get changePassword => 'Changer mon mot de passe';

  @override
  String get clearCache => 'Vider le cache local';

  @override
  String loadingError(Object error) {
    return 'Erreur de chargement: $error';
  }

  @override
  String updateError(Object error) {
    return 'Erreur mise à jour: $error';
  }

  @override
  String get updateSuccess => 'Modification enregistrée';

  @override
  String get cacheCleared => 'Cache vidé avec succès';

  @override
  String get yourBalance => 'Votre solde';

  @override
  String get amount => 'montant';

  @override
  String get payoutText => 'Gains';

  @override
  String get changePasswordTitle => 'Changer mon mot de passe';

  @override
  String get oldPasswordLabel => 'Ancien mot de passe';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get confirmPasswordLabel => 'Confirmer le nouveau mot de passe';

  @override
  String get oldPasswordEmpty => 'Veuillez entrer l\'ancien mot de passe';

  @override
  String get wrongOldPassword => 'Ancien mot de passe incorrect';

  @override
  String get passwordsDoNotMatch => 'Les nouveaux mots de passe ne correspondent pas';

  @override
  String get passwordUpdated => 'Mot de passe mis à jour avec succès';

  @override
  String errorMessage(Object error) {
    return 'Erreur: $error';
  }

  @override
  String get changePasswordButton => 'Changer le mot de passe';

  @override
  String get hoopsLeagueTitle => 'HoopsLeague';

  @override
  String get noMembersInLeague => 'Aucun membre dans cette ligue';

  @override
  String get unknownUser => 'Inconnu';

  @override
  String get pointsSuffix => 'pts';

  @override
  String get leagueNotFound => 'Ligue non trouvée';

  @override
  String get slideToBet => 'Glissez pour parier';

  @override
  String get welcomeBack => 'Bon retour sur HoopsLeague';

  @override
  String get bugReport => 'Remonter un bug';

  @override
  String get reportBug => 'Signaler un bug';

  @override
  String get describeBug => 'Décrivez le bug';

  @override
  String get send => 'Envoyer';

  @override
  String get bugEmptyError => 'La description ne peut pas être vide.';

  @override
  String get connectionSuccess => 'Connexion réussie';

  @override
  String get suggestedLeagues => 'Ligues suggérées';

  @override
  String get leagueNotFoundWithName => 'Ligue introuvable';

  @override
  String get requestAlreadySent => 'Demande déjà envoyée';

  @override
  String get requestSentPending => 'Demande envoyée, en attente d\'approbation';

  @override
  String get errorSendingRequest => 'Erreur lors de l\'envoi de la demande';

  @override
  String get userAcceptedInLeague => 'a été accepté dans la ligue';

  @override
  String get errorAcceptingUser => 'Erreur lors de l\'acceptation';

  @override
  String get userRejected => 'a été refusé';

  @override
  String get errorRejectingUser => 'Erreur lors du refus';

  @override
  String get leftLeague => 'Vous avez quitté la ligue:';

  @override
  String get errorLeavingLeague => 'Erreur lors de la sortie de la ligue';

  @override
  String get leaveLeague => 'Quitter la ligue';

  @override
  String get leaveLeagueConfirm => 'Voulez-vous vraiment quitter cette ligue ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get leave => 'Quitter';

  @override
  String get pendingRequests => 'Demandes en attente';

  @override
  String get noPendingRequests => 'Aucune demande en attente';

  @override
  String get accept => 'Accepter';

  @override
  String get reject => 'Refuser';

  @override
  String get leagueNotFoundPreview => 'Ligue introuvable';

  @override
  String get alreadyMember => 'Déjà membre';

  @override
  String get quit => 'Quitter';

  @override
  String get allRightsReserved => 'Tous droits réservés.';

  @override
  String get noGamesToday => 'Aucun match joué aujourd\'hui';

  @override
  String get securityError => 'Erreur de sécurité';

  @override
  String get unauthorizedAccess => 'Accès non autorisé';

  @override
  String get sessionExpired => 'Session expirée. Veuillez vous reconnecter.';

  @override
  String get uidError => 'Erreur UID';

  @override
  String get userLoadingError => 'Erreur chargement utilisateur';

  @override
  String get multipleBets => 'Paris multiples';

  @override
  String get singleBet => 'Pari simple';

  @override
  String get joinedLeague => 'Vous avez rejoint la ligue';

  @override
  String get alreadyInPending => 'Demande déjà envoyée';

  @override
  String get requestSent => 'Demande envoyée';

  @override
  String get nbaDisclaimer => 'Cette application est indépendante et n\'a aucun lien officiel avec la NBA.';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountConfirm => 'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.';

  @override
  String get accountDeleted => 'Compte supprimé avec succès';

  @override
  String get errorDeletingAccount => 'Erreur lors de la suppression du compte';

  @override
  String get howToUse => 'Comment utiliser l\'application';

  @override
  String get swipeToSelectTeam => 'Glissez vers la gauche ou la droite pour sélectionner l\'équipe gagnante :';

  @override
  String get errorDeletingAuthUser => 'Erreur lors de la suppression du compte d\'authentification';

  @override
  String get errorDeletingUserData => 'Erreur lors du nettoyage des données utilisateur';

  @override
  String get captchaRequired => 'Veuillez compléter la vérification CAPTCHA';

  @override
  String get captchaError => 'La vérification CAPTCHA a échoué. Veuillez réessayer.';

  @override
  String get termsAndConditions => 'Conditions Générales';

  @override
  String get privacyPolicy => 'Politique de Confidentialité';

  @override
  String get legalNotice => 'Mentions Légales';

  @override
  String get emailConfirmationTitle => 'Vérifiez votre email';

  @override
  String emailConfirmationMessage(String email) {
    return 'Un lien de confirmation a été envoyé à $email. Veuillez cliquer sur le lien pour activer votre compte.';
  }

  @override
  String get backToSignIn => 'Retour à la connexion';

  @override
  String get emailConfirmationButton => 'Compris';

  @override
  String get oddsDisclaimer => 'Les cotes sont fournies à titre informatif et ne constituent en aucun cas une incitation à parier.';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get resetPasswordTitle => 'Réinitialisez votre mot de passe';

  @override
  String get resetPasswordInstructions => 'Entrez l\'adresse email associée à votre compte. Vous recevrez un lien pour réinitialiser votre mot de passe.';

  @override
  String get sendResetLink => 'Envoyer le lien';

  @override
  String get resetEmailSent => 'Email de réinitialisation envoyé ! Veuillez vérifier votre boîte de réception.';

  @override
  String get resetEmailError => 'Erreur lors de l\'envoi de l\'email. Veuillez vérifier votre adresse email.';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get resetPasswordPageTitle => 'Définir un nouveau mot de passe';

  @override
  String get resetPasswordPageInstructions => 'Entrez votre nouveau mot de passe ci-dessous.';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get setNewPassword => 'Définir le mot de passe';

  @override
  String get passwordResetSuccess => 'Mot de passe réinitialisé avec succès ! Vous pouvez maintenant vous connecter avec votre nouveau mot de passe.';

  @override
  String get passwordResetError => 'Erreur lors de la réinitialisation du mot de passe. Le lien a peut-être expiré.';

  @override
  String get invalidResetLink => 'Lien de réinitialisation invalide ou expiré.';

  @override
  String get teamStatistics => 'Statistiques des équipes';

  @override
  String get injuredPlayers => 'Joueurs blessés';

  @override
  String get noInjuries => 'Aucune blessure signalée';

  @override
  String get lastGames => 'Derniers matchs';

  @override
  String get loading => 'Chargement...';

  @override
  String get errorLoadingStats => 'Erreur de chargement des statistiques';

  @override
  String get tapToFlipBack => 'Appuyez pour retourner';

  @override
  String get win => 'V';

  @override
  String get loss => 'D';

  @override
  String get skip => 'Passer';

  @override
  String get next => 'Suivant';

  @override
  String get finish => 'Terminer';

  @override
  String get tutorialStatsTitle => 'Appuyez pour Voir les Stats';

  @override
  String get tutorialStatsDesc => 'Appuyez sur n\'importe quelle carte de match pour la retourner et voir les statistiques détaillées des équipes, les performances des joueurs et les blessures.';

  @override
  String get tutorialSwipeTitle => 'Glissez pour Parier';

  @override
  String get tutorialSwipeDesc => 'Glissez vers la droite pour parier sur l\'équipe à domicile, ou vers la gauche pour l\'équipe extérieure. Vos sélections seront ajoutées à votre panier.';

  @override
  String get tutorialOddsTitle => 'Comprendre les Cotes';

  @override
  String get tutorialOddsDesc => 'Les cotes représentent le gain potentiel de votre pari. Des cotes plus élevées signifient un risque plus élevé mais des gains plus importants. Vous pouvez placer des paris simples ou combiner plusieurs paris pour des gains plus élevés. N\'oubliez pas : plus la cote est élevée, moins il y a de chances de gagner.';

  @override
  String get tutorialMenuTitle => 'Menu & Panier';

  @override
  String get tutorialMenuDesc => 'Accédez au menu (en haut à gauche) pour voir votre profil, l\'historique de vos paris et les paramètres. Votre panier de paris (en bas à droite) affiche vos sélections actuelles.';

  @override
  String get tutorialDailyPointsTitle => 'Points Quotidiens';

  @override
  String get tutorialDailyPointsDesc => 'Récupérez 10 points gratuits chaque jour ! Allez dans le menu et appuyez sur \'Points quotidiens\' pour les collecter. Utilisez ces points pour placer des paris et augmenter votre solde.';

  @override
  String get tutorialLeaguesTitle => 'Rejoindre des Ligues';

  @override
  String get tutorialLeaguesDesc => 'Créez ou rejoignez des ligues avec vos amis ! Affrontez-vous sur un classement basé sur vos points. Consultez les classements pour voir qui est le meilleur pronostiqueur.';

  @override
  String get gameAlreadyStarted => '⚠️ Un ou plusieurs matchs ont déjà commencé. Vous ne pouvez pas parier sur des matchs en cours.';

  @override
  String get logoutTitle => 'Déconnexion';

  @override
  String get logoutConfirmation => 'Voulez-vous vraiment vous déconnecter ?';

  @override
  String get logoutSuccess => 'Vous avez été déconnecté avec succès';

  @override
  String logoutError(Object error) {
    return 'Erreur lors de la déconnexion : $error';
  }

  @override
  String get deleteAccountTitle => 'Supprimer le compte';

  @override
  String get deleteAccountWarning => '⚠️ ATTENTION : Cette action est irréversible !\n\nEn supprimant votre compte, vous perdrez :\n• Tous vos points\n• Tous vos paris\n• Votre historique\n• Vos statistiques\n• Votre appartenance aux ligues\n\nÊtes-vous sûr de vouloir continuer ?';

  @override
  String get areYouSure => 'Êtes-vous vraiment sûr ?';

  @override
  String get deleteAccountFinalWarning => 'C\'est votre dernière chance !\n\nToutes vos données seront définitivement supprimées et vous ne pourrez pas les récupérer.\n\nVoulez-vous vraiment supprimer votre compte de manière permanente ?';

  @override
  String get deleteAccountPermanently => 'Supprimer définitivement';

  @override
  String get accountDeletedSuccess => 'Votre compte a été supprimé avec succès';

  @override
  String deleteAccountError(Object error) {
    return 'Erreur lors de la suppression du compte : $error';
  }

  @override
  String get about => 'À propos';

  @override
  String get appDescription => 'HoopsLeague est une application de paris sportifs virtuels sur les matchs NBA. Pariez avec des points virtuels, créez des ligues avec vos amis et grimpez dans les classements !';

  @override
  String get legalInformation => 'Informations légales';

  @override
  String get credits => 'Crédits';

  @override
  String get twemojiCredit => 'Les emojis utilisés dans cette application sont fournis par Twemoji, créé par Twitter. Licence CC-BY 4.0.';

  @override
  String get notoEmojiCredit => 'Police d\'emojis colorés fournie par Google. Licence Open Font License.';

  @override
  String get flutterCredit => 'Application développée avec Flutter, le framework UI de Google pour créer des applications natives.';

  @override
  String get combinedBet => 'Pari combiné';

  @override
  String get perBet => 'par pari';

  @override
  String get samePasswordError => 'Le nouveau mot de passe doit être différent de l\'actuel';

  @override
  String get previewGames => 'Voir les matchs';

  @override
  String get authRequiredTitle => 'Connexion requise';

  @override
  String get authRequiredMessage => 'Créez un compte ou connectez-vous pour placer des paris et suivre vos pronostics !';

  @override
  String get emojiLegendTitle => 'Emojis situationnels';

  @override
  String get emojiLegendSubtitle => 'Signification des emojis sur les matchs';

  @override
  String get emojiTank => 'Dernier de conférence (tank)';

  @override
  String get emojiBomb => '10 victoires consécutives';

  @override
  String get emojiCold => '5 défaites consécutives';

  @override
  String get emojiFire => '5 victoires consécutives';

  @override
  String get emojiGold => '1er de conférence';

  @override
  String get emojiSilver => '2ème de conférence';

  @override
  String get emojiBronze => '3ème de conférence';

  @override
  String get emojiHospital => '5+ joueurs blessés';

  @override
  String get emojiDefault => 'Emoji par défaut de l\'équipe';
}
