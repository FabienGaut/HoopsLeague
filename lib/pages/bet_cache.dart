import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BetCache {
  static const _boxName = 'betsBox';
  static const _prefsKey = 'bets_web';

  // Enregistre les paris localement
  static Future<void> saveBets(List<Map<String, dynamic>> bets) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(bets));
    } else {
      final box = await Hive.openBox(_boxName);
      await box.put('bets', bets);
    }
  }

  // Charge les paris du cache
  static Future<List<Map<String, dynamic>>> loadBets() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey);
      if (jsonString == null) return [];
      final List decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } else {
      final box = await Hive.openBox(_boxName);
      final data = box.get('bets', defaultValue: []);
      return List<Map<String, dynamic>>.from(data);
    }
  }

  // Vide le cache
  static Future<void> clear() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } else {
      final box = await Hive.openBox(_boxName);
      await box.delete('bets');
    }
  }
}
