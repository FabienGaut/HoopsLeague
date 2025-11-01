// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get title => 'HoopsBets';

  @override
  String get noData => 'Pas de données';

  @override
  String get noBetsSelected => 'Aucun pari';

  @override
  String get totalAmount => 'Montant total';

  @override
  String get reloadData => 'Refraîchir mes données';

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
  String get passwordTooShort =>
      'Votre mot de passe est trop court ! Il faut au moins 6 caractères !';

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
  String get confirmPasswordError =>
      'Les mots de passe ne sont pas les mêmes !';

  @override
  String get mailAlreadyUsed => 'Cet adresse email est déjà utilisée';

  @override
  String get weakPassword => 'Le mot de passe est trop faible';

  @override
  String get accountCreated => 'Votre compte a été créé avec succès';

  @override
  String get userName => 'Nom d\'utilisateur';

  @override
  String get enterUserName => 'Entrez votre nom d\'utilisateur';

  @override
  String get oddsFormat => 'Choisis ton format de cote préféré :';

  @override
  String get infosCotesCgu => 'Infos cotes & CGU';

  @override
  String get formatsDesCotes => 'Formats des cotes :';

  @override
  String get formatsDesCotesDescription =>
      '- FR : cotes décimales (ex : 2.5) → gain = mise × cote\n- US : cotes américaines (ex : +150 / -200) → gain selon montant mis\n- UK : cotes fractionnaires (ex : 5/2) → gain = mise × (numérateur / dénominateur)';

  @override
  String get cgu => 'Conditions générales (CGU) :';

  @override
  String get cguDescription =>
      '- Vous devez avoir 18 ans ou plus.\n- Les paris sont à vos risques.\n- Les informations fournies doivent être exactes.\n- Supabase HoopsBets n’est pas responsable des pertes financières.';

  @override
  String get firstConnection => 'Première connexion';
}
