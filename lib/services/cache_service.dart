import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const _pointsBox = 'user_points';

  /// Sauvegarde un nouveau point avec la date dans le même tableau (double avec 2 décimales)
  static Future<void> saveUserPoints(String uid, double points, DateTime now) async {
    final box = await Hive.openBox(_pointsBox);

    // Récupérer l’historique pour cet utilisateur
    final rawHistory = box.get(uid, defaultValue: []) as List<dynamic>;

    final history = rawHistory
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final roundedPoints = double.parse(points.toStringAsFixed(2));

    history.add({'date': now.toIso8601String(), 'points': roundedPoints});

    await box.put(uid, history);
  }



  /// Récupère l’historique complet
  static Future<List<Map<String, dynamic>>> loadPointsHistory(String uid) async {
    final box = await Hive.openBox(_pointsBox);
    final rawHistory = box.get(uid, defaultValue: []);

    return List<Map<String, dynamic>>.from(rawHistory.map((e) {
      return {
        'date': DateTime.parse(e['date']),
        'points': (e['points'] as num).toDouble(),
      };
    }));
  }

  static Future<double> loadLastPoints(String uid) async {
    final history = await loadPointsHistory(uid);
    if (history.isEmpty) return 0.0;
    return (history.last['points'] as num).toDouble();
  }

  static Future<void> clearUserCache(String uid) async {
    final box = await Hive.openBox(_pointsBox);
    await box.put(uid, []);
  }



  /// Supprime le cache complet
  static Future<void> clearCache() async {
    await Hive.deleteBoxFromDisk(_pointsBox);
  }
}
