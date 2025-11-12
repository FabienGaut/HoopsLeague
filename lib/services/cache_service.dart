import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const _pointsBox = 'user_points';

  /// Sauvegarde un nouveau point avec la date dans le même tableau (double avec 2 décimales)
  static Future<void> saveUserPoints(double points) async {
    final box = await Hive.openBox(_pointsBox);

    final today = DateTime.now();

    // Récupération sécurisée du contenu
    final rawHistory = box.get('history', defaultValue: []) as List<dynamic>;

    // Convertir proprement en List<Map<String, dynamic>>
    final history = rawHistory
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    // Arrondir à 2 décimales
    final roundedPoints = double.parse(points.toStringAsFixed(2));

    // Ajouter la nouvelle entrée
    history.add({'date': today.toIso8601String(), 'points': roundedPoints});

    await box.put('history', history);

  }


  /// Récupère l’historique complet
  static Future<List<Map<String, dynamic>>> loadPointsHistory() async {
    final box = await Hive.openBox(_pointsBox);
    final rawHistory = box.get('history', defaultValue: []);


    return List<Map<String, dynamic>>.from(rawHistory.map((e) {
      return {
        'date': DateTime.parse(e['date']),
        'points': (e['points'] as num).toDouble(),
      };
    }));
  }

  /// Récupère uniquement le dernier point enregistré
  static Future<double> loadLastPoints() async {
    final history = await loadPointsHistory();
    if (history.isEmpty) return 0.0;
    return (history.last['points'] as num).toDouble();
  }

  /// Supprime le cache complet
  static Future<void> clearCache() async {
    await Hive.deleteBoxFromDisk(_pointsBox);
  }
}
