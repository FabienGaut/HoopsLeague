import 'package:flutter_test/flutter_test.dart';
import 'package:hoopsleague/utils/time_formatter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // On initialise les données de localisation pour le formatage des dates en français.
  setUpAll(() async {
    await initializeDateFormatting('fr');
  });

  // On définit une heure de match fixe en UTC pour tous les tests.
  const gameTimeUTC = '2024-07-21T18:00:00Z'; // 18:00 UTC un dimanche

  test('formatGameTime should display correct time for Paris timezone (UTC+2)', () {
    // 1. On configure le test pour simuler un appareil à Paris
    tz.initializeTimeZones();
    final paris = tz.getLocation('Europe/Paris');
    tz.setLocalLocation(paris);

    // 2. On appelle la fonction à tester
    // 18:00 UTC devrait être 20:00 à Paris (UTC+2)
    final formattedTime = formatGameTime(gameTimeUTC, location: paris);

    // 3. On vérifie que le résultat est correct
    // Le format est 'dim. 21 juil. - 20:00'
    expect(formattedTime, contains('20:00'));
    expect(formattedTime, contains('dim. 21 juil.'));
  });

  test('formatGameTime should display correct time for Los Angeles timezone (UTC-7)', () {
    // 1. On configure le test pour simuler un appareil à Los Angeles
    tz.initializeTimeZones();
    final losAngeles = tz.getLocation('America/Los_Angeles');
    tz.setLocalLocation(losAngeles);

    // 2. On appelle la fonction à tester
    // 18:00 UTC devrait être 11:00 à Los Angeles (UTC-7)
    final formattedTime = formatGameTime(gameTimeUTC, location: losAngeles);

    // 3. On vérifie que le résultat est correct
    // Le format est 'dim. 21 juil. - 11:00'
    expect(formattedTime, contains('11:00'));
    expect(formattedTime, contains('dim. 21 juil.'));
  });

  test('formatGameTime should display correct time for Tokyo timezone (UTC+9)', () {
    // 1. On configure le test pour simuler un appareil à Tokyo
    tz.initializeTimeZones();
    final tokyo = tz.getLocation('Asia/Tokyo');
    tz.setLocalLocation(tokyo);

    // 2. On appelle la fonction à tester
    // 18:00 UTC le 21 juillet devrait être 03:00 le 22 juillet à Tokyo (UTC+9)
    final formattedTime = formatGameTime(gameTimeUTC, location: tokyo);

    // 3. On vérifie que le résultat est correct
    // Le format est 'lun. 22 juil. - 03:00'
    expect(formattedTime, contains('03:00'));
    expect(formattedTime, contains('lun. 22 juil.'));
  });
}
