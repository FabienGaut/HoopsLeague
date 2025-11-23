import 'package:flutter/material.dart';
import 'package:hoopsleague/services/clock.dart';
import 'package:provider/provider.dart';

/// Mock Clock pour les tests avec une date fixe
class MockClock extends Clock {
  final DateTime fixedTime;

  MockClock({DateTime? time})
      : fixedTime = time ?? DateTime.utc(2024, 1, 15, 12, 0);

  @override
  DateTime now() => fixedTime;

  @override
  DateTime toLocalTime(DateTime utcTime) => utcTime.toLocal();
}

/// Crée un widget de test avec les providers nécessaires
Widget createTestWidget({
  required Widget child,
  Clock? clock,
}) {
  return MaterialApp(
    home: MultiProvider(
      providers: [
        Provider<Clock>.value(value: clock ?? MockClock()),
      ],
      child: child,
    ),
  );
}

/// Données de test pour les matchs
class TestData {
  static Map<String, dynamic> createGame({
    required String id,
    required String homeTeam,
    required String awayTeam,
    required String startTime,
    double oddHome = 1.85,
    double oddAway = 2.10,
    String status = 'scheduled',
  }) {
    return {
      'id': id,
      'home_team': homeTeam,
      'away_team': awayTeam,
      'home_team_short': homeTeam.split(' ').last.substring(0, 3).toUpperCase(),
      'away_team_short': awayTeam.split(' ').last.substring(0, 3).toUpperCase(),
      'start_time': startTime,
      'odd_home_team': oddHome,
      'odd_away_team': oddAway,
      'status': status,
    };
  }

  static Map<String, dynamic> createUser({
    required String id,
    String username = 'testuser',
    double points = 1000.0,
    String oddsFormat = 'FR',
    String language = 'fr',
  }) {
    return {
      'id': id,
      'username': username,
      'points': points,
      'oddsformat': oddsFormat,
      'language': language,
      'daily_points_used': false,
    };
  }

  static Map<String, dynamic> createBet({
    required String userId,
    required String gameId,
    required String pickedTeam,
    required double odd,
    required double pointsBetted,
    String status = 'pending',
    bool rewardGiven = false,
  }) {
    return {
      'user_id': userId,
      'game_id': gameId,
      'picked_team': pickedTeam,
      'odd': odd,
      'points_betted': pointsBetted,
      'status': status,
      'reward_given': rewardGiven,
    };
  }

  /// Exemples de matchs NBA
  static final game1 = createGame(
    id: 'game-1',
    homeTeam: 'Los Angeles Lakers',
    awayTeam: 'Boston Celtics',
    startTime: '2024-01-20T02:00:00Z',
    oddHome: 1.85,
    oddAway: 2.10,
  );

  static final game2 = createGame(
    id: 'game-2',
    homeTeam: 'Golden State Warriors',
    awayTeam: 'Miami Heat',
    startTime: '2024-01-20T03:30:00Z',
    oddHome: 1.65,
    oddAway: 2.35,
  );

  static final testUser = createUser(
    id: 'user-123',
    username: 'testplayer',
    points: 1500.0,
  );
}
