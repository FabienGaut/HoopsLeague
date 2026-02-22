import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../utils/odds_converter.dart';
import '../services/cache_service.dart';

class AppState extends ChangeNotifier {
  Locale _locale = const Locale('fr');
  Map<String, dynamic>? _userData;
  StreamSubscription? _userDataSubscription;
  String? _currentUserId;

  Locale get locale => _locale;
  Map<String, dynamic>? get userData => _userData;
  String get oddsFormat => (_userData?['oddsformat'] ?? 'FR') as String;

  void setLocale(String langCode) {
    _locale = Locale(langCode);
    notifyListeners();
  }

  Future<void> loadUserData(String userId) async {
    _currentUserId = userId;

    // 🔧 FIX: Add retry logic for initial load
    const maxRetries = 3;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Load user data from database
        final data = await Supabase.instance.client
            .from('usersdata')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (data != null) {
          _userData = data;
          notifyListeners();
          debugPrint('✅ User data loaded successfully (attempt $attempt)');
          break;
        } else {
          debugPrint('⚠️ User data is null (attempt $attempt)');
          if (attempt == maxRetries) {
            debugPrint('❌ Failed to load user data after $maxRetries attempts');
          }
        }
      } catch (e) {
        debugPrint('Error loading user data (attempt $attempt): $e');
        if (attempt < maxRetries) {
          // Wait before retrying (exponential backoff)
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
    }

    // Note: Real-time stream disabled to avoid WebSocket errors
    // Data will be refreshed manually when needed
    _userDataSubscription?.cancel();
    _userDataSubscription = null;
  }

  Future<void> refreshUserData() async {
    if (_currentUserId != null) {
      try {
        // 🔧 FIX: Load fresh data from database FIRST
        final data = await Supabase.instance.client
            .from('usersdata')
            .select()
            .eq('id', _currentUserId!)
            .maybeSingle();

        if (data != null) {
          _userData = data;
          notifyListeners();
        }

        // Then sync any won bets (now using fresh _userData)
        await syncWonBets();

        // Reload data again after syncWonBets to get updated points
        final updatedData = await Supabase.instance.client
            .from('usersdata')
            .select()
            .eq('id', _currentUserId!)
            .maybeSingle();

        if (updatedData != null) {
          _userData = updatedData;
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error refreshing user data: $e');
      }
    }
  }

  /// Syncs won bets and credits points to the user
  Future<Map<String, dynamic>?> syncWonBets() async {
    if (_currentUserId == null) return null;

    debugPrint('=== SYNC WON BETS START ===');
    debugPrint('User ID: $_currentUserId');

    try {
      final supabase = Supabase.instance.client;

      // 1️⃣ Get all user bets
      final bets = await supabase
          .from('bets')
          .select('id, points_betted, odd, status, reward_given')
          .eq('user_id', _currentUserId!);

      debugPrint('Found ${bets.length} total bets');

      double totalWon = 0;
      final List<String> betIdsToUpdate = [];

      // 2️⃣ Calculate uncredited winnings
      for (var bet in bets) {
        final isWon = bet['status'] == 'won';
        final alreadyCredited = bet['reward_given'] ?? false;

        debugPrint('Bet ${bet['id']}: status=${bet['status']}, reward_given=$alreadyCredited');

        if (isWon && !alreadyCredited) {
          final amount = (bet['points_betted'] ?? 0).toDouble();
          final odd = (bet['odd'] ?? 1.0).toDouble();
          final winAmount = amount * odd;
          totalWon += winAmount;

          debugPrint('  -> Won bet! Amount: $amount, Odd: $odd, Win: $winAmount');

          betIdsToUpdate.add(bet['id'].toString());
        }
      }

      debugPrint('Total won: $totalWon');
      debugPrint('Bets to update: $betIdsToUpdate');

      // 3️⃣ Update reward_given for all won bets
      if (betIdsToUpdate.isNotEmpty) {
        await supabase
            .from('bets')
            .update({'reward_given': true})
            .inFilter('id', betIdsToUpdate);

        debugPrint('✅ Updated ${betIdsToUpdate.length} bets to reward_given=true');
      }

      // 4️⃣ If there are winnings, update user points
      if (totalWon > 0) {
        // 🔧 FIX: Fetch current points directly from database to avoid stale data
        final freshUserData = await supabase
            .from('usersdata')
            .select('points')
            .eq('id', _currentUserId!)
            .maybeSingle();

        final currentPoints = (freshUserData?['points'] ?? 0).toDouble();
        final newPoints = currentPoints + totalWon;

        await supabase
            .from('usersdata')
            .update({'points': newPoints.toInt()})
            .eq('id', _currentUserId!);

        // Sauvegarder dans l'historique des points
        await CacheService.savePointsToHistory(_currentUserId!, newPoints);

        debugPrint('✅ Credited $totalWon points (${currentPoints.toInt()} -> ${newPoints.toInt()})');

        return {
          'totalWon': totalWon,
          'newPoints': newPoints.toInt(),
        };
      }

      debugPrint('=== SYNC WON BETS COMPLETE (no new winnings) ===');
      return null;
    } catch (e, stackTrace) {
      debugPrint('Error syncing won bets: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  String convertOdds(double frOdd) {
    return OddsConverter.convert(frOdd, oddsFormat);
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    super.dispose();
  }
}


// Instancier une seule fois pour l'utiliser globalement
final AppState appState = AppState();
