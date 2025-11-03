import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const _pointsBox = 'user_points';
  static Future<void> saveUserPoints(int points) async {
    final box = await Hive.openBox('user');
    await box.put('points', {
      'value': points,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> saveUserPointsWithDate(int points) async {
    final box = await Hive.openBox(_pointsBox);
    final today = DateTime.now();
    final history = box.get('history', defaultValue: []) as List;
    // Ajouter le nouveau point du jour
    history.add({'date': today.toIso8601String(), 'points': points});
    await box.put('history', history);
  }

  static Future<int> loadLastPoints() async {
    final box = await Hive.openBox(_pointsBox);
    final history = box.get('history', defaultValue: []) as List;
    if (history.isEmpty) return 0;
    return history.last['points'] as int;
  }

  /// Supprime le cache complet
  static Future<void> clearCache() async {
    await Hive.deleteBoxFromDisk(_pointsBox);
  }

  static Future<List<Map<String, dynamic>>> loadPointsHistory() async {
    final box = await Hive.openBox(_pointsBox);
    final history = box.get('history', defaultValue: []) as List;
    return history.map((e) {
      return {
        'date': DateTime.parse(e['date']),
        'points': e['points'] as int,
      };
    }).toList();
  }

  static Future<Map<String, dynamic>> loadUserPoints() async {
    final box = await Hive.openBox('user');
    final data = box.get('points', defaultValue: {'value': 0, 'timestamp': null});
    return {
      'value': data['value'] ?? 0,
      'timestamp': data['timestamp'],
    };
  }
}

