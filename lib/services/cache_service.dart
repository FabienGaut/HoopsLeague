import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CacheService {
  static final _supabase = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> loadPointsHistory(String uid) async {
    try {
      final response = await _supabase
          .from('usersdata')
          .select('points_history')
          .eq('id', uid)
          .single();

      final rawHistory = response['points_history'] as List<dynamic>?;

      if (rawHistory == null || rawHistory.isEmpty) {
        return [];
      }

      return rawHistory.map((entry) {
        final map = entry as Map<String, dynamic>;
        final timestamp = (map['t'] as num).toInt();
        final points = (map['p'] as num).toDouble();

        return {
          'date': DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
          'points': points,
        };
      }).toList();
    } catch (e) {
      debugPrint('Erreur loadPointsHistory: $e');
      return [];
    }
  }

  static Future<void> savePointsToHistory(String uid, double points) async {
    try {
      final response = await _supabase
          .from('usersdata')
          .select('points_history')
          .eq('id', uid)
          .single();

      final rawHistory = response['points_history'] as List<dynamic>? ?? [];
      final history = List<Map<String, dynamic>>.from(rawHistory);

      final now = DateTime.now();
      final timestampSeconds = now.millisecondsSinceEpoch ~/ 1000;

      history.add({
        't': timestampSeconds,
        'p': points.round(),
      });

      await _supabase
          .from('usersdata')
          .update({'points_history': history})
          .eq('id', uid);
    } catch (e) {
      debugPrint('Erreur savePointsToHistory: $e');
    }
  }

  static Future<double> loadLastPoints(String uid) async {
    final history = await loadPointsHistory(uid);
    if (history.isEmpty) return 0.0;
    return (history.last['points'] as num).toDouble();
  }
}
