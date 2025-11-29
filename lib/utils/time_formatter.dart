import 'package:intl/intl.dart';

/// Formate une chaîne de caractères UTC en une heure locale lisible.
///
/// Exemple : '2024-07-20T10:00:00Z' deviendra 'sam. 20 juil. - 12:00' si
/// l'appareil est en heure de Paris (UTC+2).
String formatGameTime(String utcString) {
  try {
    // On s'assure que la date est bien interprétée comme UTC
    final utcTime = DateTime.parse(utcString).toUtc();
    // On la convertit dans le fuseau horaire local de l'appareil
    final localTime = utcTime.toLocal();
    // On la formate. Le 'fr' assure que les jours et mois sont en français.
    return DateFormat('EEE d MMM - HH:mm', 'fr').format(localTime);
  } catch (_) {
    // En cas d'erreur, on retourne la chaîne originale.
    return utcString;
  }
}
