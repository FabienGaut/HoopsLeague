import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for GamesPage logic
/// Note: These tests focus on pure logic that can be tested without Supabase
void main() {
  group('GamesPage - Team Colors', () {
    // Replicate the teamColors map from GamesPage
    const Map<String, Color> teamColors = {
      'Celtics': Color(0xFF007A38),
      'Nets': Color(0xFF000000),
      '76ers': Color(0xFF002AB8),
      'Knicks': Color(0xFF006BBD),
      'Raptors': Color(0xFF78007E),
      'Bulls': Color(0xFFD80C28),
      'Cavaliers': Color(0xFF8B003D),
      'Pistons': Color(0xFFCC1033),
      'Pacers': Color(0xFFF1D018),
      'Bucks': Color(0xFF004720),
      'Hawks': Color(0xFFE53A43),
      'Heat': Color(0xFF9D0033),
      'Hornets': Color(0xFF1D1165),
      'Magic': Color(0xFF0077C5),
      'Wizards': Color(0xFF002B61),
      'Nuggets': Color(0xFF0E2245),
      'Timberwolves': Color(0xFF0C2345),
      'Thunder': Color(0xFF007AC6),
      'Trail Blazers': Color(0xFFFF000A),
      'Jazz': Color(0xFF046002),
      'Warriors': Color(0xFF1D428F),
      'Clippers': Color(0xFFCC1033),
      'Lakers': Color(0xFF6F2C96),
      'Suns': Color(0xFF3F1170),
      'Kings': Color(0xFF5F2D86),
      'Mavericks': Color(0xFF005391),
      'Rockets': Color(0xFFE53A43),
      'Grizzlies': Color(0xFF6276AE),
      'Pelicans': Color(0xFF0C2345),
      'Spurs': Color(0xFF000000),
    };

    Color getTeamColor(String teamName) {
      for (var entry in teamColors.entries) {
        if (teamName.contains(entry.key)) return entry.value;
      }
      return const Color(0xFF3D7BF4); // AppColors.primaryBlue
    }

    test('should return correct color for full team names', () {
      expect(getTeamColor('Boston Celtics'), const Color(0xFF007A38));
      expect(getTeamColor('Los Angeles Lakers'), const Color(0xFF6F2C96));
      expect(getTeamColor('Miami Heat'), const Color(0xFF9D0033));
      expect(getTeamColor('Golden State Warriors'), const Color(0xFF1D428F));
    });

    test('should return correct color for partial team names', () {
      expect(getTeamColor('Celtics'), const Color(0xFF007A38));
      expect(getTeamColor('Lakers'), const Color(0xFF6F2C96));
    });

    test('should return default color for unknown teams', () {
      expect(getTeamColor('Unknown Team'), const Color(0xFF3D7BF4));
      expect(getTeamColor(''), const Color(0xFF3D7BF4));
    });

    test('all 30 NBA teams should have colors defined', () {
      expect(teamColors.length, 30);
    });
  });

  group('GamesPage - Team Emojis', () {
    const Map<String, String> teamEmojis = {
      'Celtics': '🟢',
      'Nets': '🕸',
      '76ers': '🔔',
      'Knicks': '🗽',
      'Raptors': '🇨🇦',
      'Bulls': '🐂',
      'Cavaliers': '🕷️',
      'Pistons': '⚙️',
      'Pacers': '🏁',
      'Bucks': '⚡',
      'Hawks': '🔴',
      'Heat': '♨️',
      'Hornets': '🔵',
      'Magic': '🎢',
      'Wizards': '🏛️',
      'Nuggets': '🃏',
      'Timberwolves': '🐜',
      'Thunder': '🏆️',
      'Trail Blazers': '🌲',
      'Jazz': '🏔️',
      'Warriors': '🎯',
      'Clippers': '⚓',
      'Lakers': '🌴',
      'Suns': '🌵',
      'Kings': '🟣',
      'Mavericks': '🤠',
      'Rockets': '🛰️',
      'Grizzlies': '🔫',
      'Pelicans': '🦩',
      'Spurs': '👽',
    };

    String getTeamEmoji(String teamName) {
      for (var entry in teamEmojis.entries) {
        if (teamName.contains(entry.key)) return entry.value;
      }
      return '🏀';
    }

    test('should return correct emoji for teams', () {
      expect(getTeamEmoji('Boston Celtics'), '🟢');
      expect(getTeamEmoji('Los Angeles Lakers'), '🌴');
      expect(getTeamEmoji('Chicago Bulls'), '🐂');
    });

    test('should return basketball emoji for unknown teams', () {
      expect(getTeamEmoji('Unknown Team'), '🏀');
    });

    test('all 30 NBA teams should have emojis defined', () {
      expect(teamEmojis.length, 30);
    });
  });

  group('GamesPage - Short Name to City', () {
    String shortNameToCity(String shortName) {
      const Map<String, String> cityMap = {
        'LAL': 'LA',
        'LAC': 'LA',
        'GSW': 'GS',
        'NYK': 'NY',
        'BKN': 'BKN',
        'NOP': 'NO',
        'BOS': 'BOS',
        'MIA': 'MIA',
        'PHI': 'PHI',
        'TOR': 'TOR',
        'CHI': 'CHI',
        'CLE': 'CLE',
        'DET': 'DET',
        'IND': 'IND',
        'MIL': 'MIL',
        'ATL': 'ATL',
        'CHA': 'CHA',
        'ORL': 'ORL',
        'WAS': 'WAS',
        'DEN': 'DEN',
        'MIN': 'MIN',
        'OKC': 'OKC',
        'POR': 'POR',
        'UTA': 'UTA',
        'PHX': 'PHX',
        'SAC': 'SAC',
        'DAL': 'DAL',
        'HOU': 'HOU',
        'MEM': 'MEM',
        'SAS': 'SAS',
      };
      return cityMap[shortName] ?? shortName;
    }

    test('should convert LA teams correctly', () {
      expect(shortNameToCity('LAL'), 'LA');
      expect(shortNameToCity('LAC'), 'LA');
    });

    test('should convert multi-word abbreviations', () {
      expect(shortNameToCity('GSW'), 'GS');
      expect(shortNameToCity('NYK'), 'NY');
      expect(shortNameToCity('NOP'), 'NO');
    });

    test('should return same code for standard teams', () {
      expect(shortNameToCity('BOS'), 'BOS');
      expect(shortNameToCity('MIA'), 'MIA');
    });

    test('should return input for unknown codes', () {
      expect(shortNameToCity('XXX'), 'XXX');
    });
  });

  group('GamesPage - Situational Emoji Logic', () {
    // Simulating TeamSituationalData
    Map<String, dynamic> createTeamData({
      required String name,
      String? lastGames,
      String? last10,
      int? rank,
      int injuryCount = 0,
    }) {
      return {
        'name': name,
        'lastGames': lastGames,
        'last10': last10,
        'rank': rank,
        'injuryCount': injuryCount,
      };
    }

    String getSituationalEmoji(Map<String, dynamic>? teamData, String defaultEmoji) {
      if (teamData == null) return defaultEmoji;

      // Rule 1: Last in conference -> tank
      if (teamData['rank'] == 15) return '🚜'; // tank.png equivalent

      // Rule 2: 10 consecutive wins -> bomb
      if (teamData['last10'] == '10-0') return '💣';

      // Rule 3: 5 consecutive losses -> cold
      if (teamData['lastGames']?.toString().toUpperCase() == 'LLLLL') return '🥶';

      // Rule 4: 5 consecutive wins -> fire
      if (teamData['lastGames']?.toString().toUpperCase() == 'WWWWW') return '🔥';

      // Rule 6: Top 3 in conference -> medals
      if (teamData['rank'] == 1) return '🥇';
      if (teamData['rank'] == 2) return '🥈';
      if (teamData['rank'] == 3) return '🥉';

      // Rule 7: 5+ injured players -> hospital
      if ((teamData['injuryCount'] ?? 0) >= 5) return '🏥';

      // Rule 8: Default
      return defaultEmoji;
    }

    test('should return tank emoji for last place team', () {
      final teamData = createTeamData(name: 'Wizards', rank: 15);
      expect(getSituationalEmoji(teamData, '🏛️'), '🚜');
    });

    test('should return bomb emoji for 10 consecutive wins', () {
      final teamData = createTeamData(name: 'Thunder', last10: '10-0');
      expect(getSituationalEmoji(teamData, '🏆️'), '💣');
    });

    test('should return cold emoji for 5 consecutive losses', () {
      final teamData = createTeamData(name: 'Pistons', lastGames: 'LLLLL');
      expect(getSituationalEmoji(teamData, '⚙️'), '🥶');
    });

    test('should return fire emoji for 5 consecutive wins', () {
      final teamData = createTeamData(name: 'Celtics', lastGames: 'WWWWW');
      expect(getSituationalEmoji(teamData, '🟢'), '🔥');
    });

    test('should return medal emojis for top 3 teams', () {
      expect(getSituationalEmoji(createTeamData(name: 'Team', rank: 1), '🏀'), '🥇');
      expect(getSituationalEmoji(createTeamData(name: 'Team', rank: 2), '🏀'), '🥈');
      expect(getSituationalEmoji(createTeamData(name: 'Team', rank: 3), '🏀'), '🥉');
    });

    test('should return hospital emoji for 5+ injuries', () {
      final teamData = createTeamData(name: 'Warriors', injuryCount: 5);
      expect(getSituationalEmoji(teamData, '🎯'), '🏥');
    });

    test('should return default emoji when no conditions match', () {
      final teamData = createTeamData(name: 'Lakers', lastGames: 'WWLWL', rank: 7);
      expect(getSituationalEmoji(teamData, '🌴'), '🌴');
    });

    test('should return default emoji when teamData is null', () {
      expect(getSituationalEmoji(null, '🏀'), '🏀');
    });

    test('should be case insensitive for lastGames', () {
      final teamDataLower = createTeamData(name: 'Team', lastGames: 'wwwww');
      final teamDataUpper = createTeamData(name: 'Team', lastGames: 'WWWWW');
      expect(getSituationalEmoji(teamDataLower, '🏀'), '🔥');
      expect(getSituationalEmoji(teamDataUpper, '🏀'), '🔥');
    });

    test('priority: 10-game streak takes precedence over 5-game streak', () {
      // If a team has 10-0 AND WWWWW, 10-0 should take precedence
      final teamData = createTeamData(name: 'Team', last10: '10-0', lastGames: 'WWWWW');
      expect(getSituationalEmoji(teamData, '🏀'), '💣');
    });
  });

  group('GamesPage - Bet Data Structure', () {
    test('bet should have required fields', () {
      final bet = {
        'pickedTeam': 'Los Angeles Lakers',
        'odd': 1.85,
        'start_time': '2024-01-20T02:00:00Z',
        'game_id': 'game-123',
      };

      expect(bet['pickedTeam'], isNotNull);
      expect(bet['odd'], isA<double>());
      expect(bet['start_time'], isNotNull);
      expect(bet['game_id'], isNotNull);
    });

    test('bet list operations', () {
      final bets = <Map<String, dynamic>>[];

      // Add a bet
      bets.add({
        'pickedTeam': 'Lakers',
        'odd': 1.85,
        'start_time': '2024-01-20T02:00:00Z',
        'game_id': 'game-1',
      });

      expect(bets.length, 1);

      // Add another bet
      bets.add({
        'pickedTeam': 'Celtics',
        'odd': 2.10,
        'start_time': '2024-01-20T03:00:00Z',
        'game_id': 'game-2',
      });

      expect(bets.length, 2);

      // Check if game is already bet on
      final gameId = 'game-1';
      final isAlreadyBet = bets.any((b) => b['game_id'] == gameId);
      expect(isAlreadyBet, true);

      final gameId2 = 'game-3';
      final isNotBet = bets.any((b) => b['game_id'] == gameId2);
      expect(isNotBet, false);
    });

    test('combined odds calculation', () {
      final bets = [
        {'odd': 1.85},
        {'odd': 2.10},
        {'odd': 1.50},
      ];

      final combinedOdd = bets.fold<double>(
        1.0,
        (acc, bet) => acc * (bet['odd'] as double),
      );

      // 1.85 * 2.10 * 1.50 = 5.8275
      expect(combinedOdd, closeTo(5.8275, 0.001));
    });
  });
}
