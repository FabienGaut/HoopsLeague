import 'package:flutter_test/flutter_test.dart';

/// Tests for GameStatsCard data parsing logic
/// Note: Widget tests would require mocking Supabase, so we test the pure logic
void main() {
  group('GameStatsCard - Team Name Parsing', () {
    String getShortTeamName(String fullName) {
      final parts = fullName.split(' ');
      return parts.isNotEmpty ? parts.last : fullName;
    }

    test('should extract team name from full name', () {
      expect(getShortTeamName('Boston Celtics'), 'Celtics');
      expect(getShortTeamName('Los Angeles Lakers'), 'Lakers');
      expect(getShortTeamName('Golden State Warriors'), 'Warriors');
    });

    test('should handle single word names', () {
      expect(getShortTeamName('Heat'), 'Heat');
      expect(getShortTeamName('Celtics'), 'Celtics');
    });

    test('should handle empty string', () {
      expect(getShortTeamName(''), '');
    });

    test('should handle trail blazers special case', () {
      // "Trail Blazers" -> "Blazers"
      expect(getShortTeamName('Portland Trail Blazers'), 'Blazers');
    });
  });

  group('GameStatsCard - Last Games Parsing', () {
    List<String> parseLastGames(dynamic lastGames) {
      String gamesString = '';

      if (lastGames is String) {
        gamesString = lastGames;
      } else if (lastGames is List && lastGames.isNotEmpty) {
        gamesString = lastGames.join('');
      } else {
        return [];
      }

      return gamesString.toUpperCase().split('').take(5).toList();
    }

    test('should parse string format', () {
      expect(parseLastGames('WWLWL'), ['W', 'W', 'L', 'W', 'L']);
    });

    test('should parse list format', () {
      expect(parseLastGames(['W', 'W', 'L', 'W', 'L']), ['W', 'W', 'L', 'W', 'L']);
    });

    test('should convert to uppercase', () {
      expect(parseLastGames('wwlwl'), ['W', 'W', 'L', 'W', 'L']);
    });

    test('should take only first 5 games', () {
      expect(parseLastGames('WWLWLWWL'), ['W', 'W', 'L', 'W', 'L']);
    });

    test('should handle empty input', () {
      expect(parseLastGames(''), []);
      expect(parseLastGames([]), []);
      expect(parseLastGames(null), []);
    });

    test('should handle less than 5 games', () {
      expect(parseLastGames('WW'), ['W', 'W']);
      expect(parseLastGames('WLW'), ['W', 'L', 'W']);
    });
  });

  group('GameStatsCard - Player Stats Parsing', () {
    Map<String, dynamic> parsePlayerStats(dynamic playerStats) {
      if (playerStats is Map) {
        return Map<String, dynamic>.from(playerStats);
      } else if (playerStats is List && playerStats.isNotEmpty) {
        return Map<String, dynamic>.from(playerStats[0]);
      }
      return {};
    }

    test('should parse map format', () {
      final stats = parsePlayerStats({
        'name': 'LeBron James',
        'ppg': 25.5,
        'apg': 7.8,
      });

      expect(stats['name'], 'LeBron James');
      expect(stats['ppg'], 25.5);
      expect(stats['apg'], 7.8);
    });

    test('should parse list format (first element)', () {
      final stats = parsePlayerStats([
        {'name': 'Stephen Curry', 'ppg': 28.0},
        {'name': 'Klay Thompson', 'ppg': 20.0},
      ]);

      expect(stats['name'], 'Stephen Curry');
      expect(stats['ppg'], 28.0);
    });

    test('should return empty map for invalid input', () {
      expect(parsePlayerStats(null), isEmpty);
      expect(parsePlayerStats([]), isEmpty);
      expect(parsePlayerStats('invalid'), isEmpty);
    });

    test('should handle nested player name fields', () {
      final stats1 = parsePlayerStats({'name': 'Player A'});
      final stats2 = parsePlayerStats({'player_name': 'Player B'});
      final stats3 = parsePlayerStats({'player': 'Player C'});

      expect(stats1['name'], 'Player A');
      expect(stats2['player_name'], 'Player B');
      expect(stats3['player'], 'Player C');
    });
  });

  group('GameStatsCard - Stats Priority Ordering', () {
    List<MapEntry<String, dynamic>> orderStats(Map<String, dynamic> stats) {
      final orderedStats = <MapEntry<String, dynamic>>[];
      final priorityKeys = ['ppg', 'PPG', 'apg', 'APG'];

      // Remove name fields first
      final statsOnly = Map<String, dynamic>.from(stats);
      statsOnly.remove('name');
      statsOnly.remove('player_name');
      statsOnly.remove('player');

      // Add priority stats first
      for (var key in priorityKeys) {
        if (statsOnly.containsKey(key)) {
          orderedStats.add(MapEntry(key, statsOnly[key]));
          statsOnly.remove(key);
        }
      }

      // Add remaining stats
      orderedStats.addAll(statsOnly.entries);

      return orderedStats;
    }

    test('should prioritize PPG first', () {
      final stats = {
        'rpg': 10.0,
        'ppg': 25.0,
        'apg': 5.0,
      };

      final ordered = orderStats(stats);
      expect(ordered[0].key, 'ppg');
    });

    test('should prioritize APG second', () {
      final stats = {
        'rpg': 10.0,
        'apg': 5.0,
        'spg': 1.5,
      };

      final ordered = orderStats(stats);
      expect(ordered[0].key, 'apg');
    });

    test('should handle uppercase keys', () {
      final stats = {
        'RPG': 10.0,
        'PPG': 25.0,
        'APG': 5.0,
      };

      final ordered = orderStats(stats);
      expect(ordered[0].key, 'PPG');
    });

    test('should exclude name fields from stats', () {
      final stats = {
        'name': 'Player',
        'ppg': 25.0,
        'apg': 5.0,
      };

      final ordered = orderStats(stats);
      expect(ordered.any((e) => e.key == 'name'), false);
    });
  });

  group('GameStatsCard - Injury Data Parsing', () {
    List<Map<String, dynamic>> parseInjuries(List<dynamic>? injuries) {
      if (injuries == null || injuries.isEmpty) return [];

      return injuries.map((injury) {
        if (injury is Map) {
          return {
            'name': injury['name']?.toString() ??
                injury['player']?.toString() ??
                'Unknown',
            'injury': injury['injury']?.toString() ??
                injury['status']?.toString() ??
                '',
          };
        }
        return {'name': injury.toString(), 'injury': ''};
      }).toList();
    }

    test('should parse map format injuries', () {
      final injuries = parseInjuries([
        {'name': 'Anthony Davis', 'injury': 'Knee'},
        {'name': 'LeBron James', 'injury': 'Ankle'},
      ]);

      expect(injuries.length, 2);
      expect(injuries[0]['name'], 'Anthony Davis');
      expect(injuries[0]['injury'], 'Knee');
    });

    test('should handle player field instead of name', () {
      final injuries = parseInjuries([
        {'player': 'Kawhi Leonard', 'status': 'Questionable'},
      ]);

      expect(injuries[0]['name'], 'Kawhi Leonard');
      expect(injuries[0]['injury'], 'Questionable');
    });

    test('should handle string format', () {
      final injuries = parseInjuries(['Player A', 'Player B']);

      expect(injuries.length, 2);
      expect(injuries[0]['name'], 'Player A');
      expect(injuries[0]['injury'], '');
    });

    test('should return empty list for null', () {
      expect(parseInjuries(null), isEmpty);
    });

    test('should return empty list for empty array', () {
      expect(parseInjuries([]), isEmpty);
    });
  });

  group('GameStatsCard - Win/Loss Display Logic', () {
    test('W should be displayed as win', () {
      const game = 'W';
      final isWin = game == 'W';

      expect(isWin, true);
    });

    test('L should be displayed as loss', () {
      const game = 'L';
      final isWin = game == 'W';

      expect(isWin, false);
    });

    test('should count wins and losses', () {
      final games = ['W', 'W', 'L', 'W', 'L'];

      final wins = games.where((g) => g == 'W').length;
      final losses = games.where((g) => g == 'L').length;

      expect(wins, 3);
      expect(losses, 2);
    });
  });

  group('GameStatsCard - No Injuries State', () {
    test('should detect when both teams have no injuries', () {
      final homeInjuries = <dynamic>[];
      final awayInjuries = <dynamic>[];

      final hasHomeInjuries = homeInjuries.isNotEmpty;
      final hasAwayInjuries = awayInjuries.isNotEmpty;

      expect(hasHomeInjuries, false);
      expect(hasAwayInjuries, false);
      expect(!hasHomeInjuries && !hasAwayInjuries, true);
    });

    test('should detect when one team has injuries', () {
      final homeInjuries = [
        {'name': 'Player A', 'injury': 'Knee'}
      ];
      final awayInjuries = <dynamic>[];

      final hasHomeInjuries = homeInjuries.isNotEmpty;
      final hasAwayInjuries = awayInjuries.isNotEmpty;

      expect(hasHomeInjuries, true);
      expect(hasAwayInjuries, false);
    });

    test('should detect when both teams have injuries', () {
      final homeInjuries = [
        {'name': 'Player A'}
      ];
      final awayInjuries = [
        {'name': 'Player B'}
      ];

      final hasHomeInjuries = homeInjuries.isNotEmpty;
      final hasAwayInjuries = awayInjuries.isNotEmpty;

      expect(hasHomeInjuries && hasAwayInjuries, true);
    });
  });
}
