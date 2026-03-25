import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hoopsleague/pages/main_navigation.dart';

import 'package:hoopsleague/services/clock.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import 'package:hoopsleague/theme/utils.dart';
import 'package:hoopsleague/theme/app_colors.dart';
import 'package:hoopsleague/services/cache_service.dart';
import '../utils/security_utils.dart';
import '../widgets/flip_card_widget.dart';
import '../widgets/game_stats_card.dart';
import '../widgets/tutorial_overlay.dart';
import 'app_state.dart';
import 'playoff_bracket_page.dart';

final supabase = Supabase.instance.client;

class TeamSituationalData {
  final String name;
  final String? lastGames;
  final String? last10;
  final int? rank;
  final int injuryCount;

  TeamSituationalData({
    required this.name,
    this.lastGames,
    this.last10,
    this.rank,
    this.injuryCount = 0,
  });

  TeamSituationalData withInjuryCount(int count) {
    return TeamSituationalData(
      name: name,
      lastGames: lastGames,
      last10: last10,
      rank: rank,
      injuryCount: count,
    );
  }
}

class GamesPage extends StatefulWidget {
  final String? uid;
  final bool showTutorial;
  final VoidCallback? onAuthRequired;

  const GamesPage({super.key, this.uid, this.showTutorial = false, this.onAuthRequired});

  bool get isPreviewMode => uid == null;

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final List<Map<String, dynamic>> bets = [];
  final ValueNotifier<List<Map<String, dynamic>>> betsNotifier = ValueNotifier([]);
  bool isLoading = true;
  bool _showTutorialOverlay = false;
  List<Map<String, dynamic>> _upcomingGames = [];
  bool _isRefreshingGames = false;

  // Situational data for dynamic emojis
  Map<String, TeamSituationalData> _teamSituationalData = {};
  Map<dynamic, Map<String, int>> _gameInjuryCounts = {};

  // Cache for team colors and emojis to avoid repeated lookups
  final Map<String, Color> _teamColorCache = {};
  final Map<String, String> _teamEmojiCache = {};

  static const Map<String, String> teamEmojis = {
    'Celtics': '🍀',
    'Nets': '🕸',
    '76ers': '🔔',
    'Knicks': '🗽',
    'Raptors': '🦖',
    'Bulls': '🐂',
    'Cavaliers': '🛡️',
    'Pistons': '🔧',
    'Pacers': '🏁',
    'Bucks': '🦌',
    'Hawks': '🦅',
    'Heat': '🔥',
    'Hornets': '🐝',
    'Magic': '🪄',
    'Wizards': '🧙',
    'Nuggets': '⛏️',
    'Timberwolves': '🐺',
    'Thunder': '⚡',
    'Trail Blazers': '🌲',
    'Jazz': '🎷',
    'Warriors': '⚔️',
    'Clippers': '⛵',
    'Lakers': '🌴',
    'Suns': '☀️',
    'Kings': '👑',
    'Mavericks': '🤠',
    'Rockets': '🚀',
    'Grizzlies': '🐻',
    'Pelicans': '🦩',
    'Spurs': '👽',
  };

  static const Map<String, Color> teamColors = {
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
    // Use cache to avoid repeated lookups
    return _teamColorCache.putIfAbsent(teamName, () {
      for (var entry in teamColors.entries) {
        if (teamName.contains(entry.key)) return entry.value;
      }
      return AppColors.primaryBlue;
    });
  }

  String getTeamEmoji(String teamName) {
    // Use cache to avoid repeated lookups
    return _teamEmojiCache.putIfAbsent(teamName, () {
      for (var entry in teamEmojis.entries) {
        if (teamName.contains(entry.key)) return entry.value;
      }
      return '🏀';
    });
  }

  TeamSituationalData? getTeamDataWithInjuries(
    String teamName,
    dynamic gameId,
    bool isHome,
  ) {
    final baseData = _teamSituationalData[teamName];
    if (baseData == null) return null;

    final gameInjuries = _gameInjuryCounts[gameId];
    final injuryCount = isHome
        ? (gameInjuries?['home'] ?? 0)
        : (gameInjuries?['away'] ?? 0);

    return baseData.withInjuryCount(injuryCount);
  }

  Widget getSituationalEmojiWidget(
    BuildContext context,
    String teamName,
    TeamSituationalData? teamData,
  ) {
    final double emojiSize = logScale(context, 26);

    // Helper to create emoji Text widget
    Widget emojiText(String emoji) {
      return Text(
        emoji,
        style: TextStyle(
          fontSize: emojiSize,
        ),
      );
    }

    if (teamData == null) {
      return emojiText(getTeamEmoji(teamName));
    }

    // Rule 1: Last in conference -> tank.png
    if (teamData.rank == 15) {
      return Image.asset(
        'assets/images/tank.png',
        width: emojiSize,
        height: emojiSize,
        fit: BoxFit.contain,
      );
    }

    // Rule 2: 10 consecutive wins -> bomb
    if (teamData.last10 == '10-0') {
      return emojiText('💣');
    }

    // Rule 3: 5 consecutive losses -> cold
    if (teamData.lastGames?.toUpperCase() == 'LLLLL') {
      return emojiText('🥶');
    }

    // Rule 4: 5 consecutive wins -> fire
    if (teamData.lastGames?.toUpperCase() == 'WWWWW') {
      return emojiText('🔥');
    }

    // Rule 6: Top 3 in conference -> medal
    if (teamData.rank != null && teamData.rank! == 3) {
      return emojiText('🥉');
    }
    if (teamData.rank != null && teamData.rank! == 2) {
      return emojiText('🥈');
    }
    if (teamData.rank != null && teamData.rank! == 1) {
      return emojiText('🥇');
    }

    // Rule 7: 4+ injured players -> hospital
    if (teamData.injuryCount >= 5) {
      return emojiText('🏥');
    }

    // Rule 8: Default -> static team emoji
    return emojiText(getTeamEmoji(teamName));
  }

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

  String formatGameTime(String utcString, Clock clock) {
    try {
      final utcTime = DateTime.parse(utcString).toUtc();
      final localTime = clock.toLocalTime(utcTime);
      final locale = Localizations.localeOf(context).toString();
      return DateFormat('EEE d MMM - HH:mm', locale).format(localTime);
    } catch (_) {
      return utcString;
    }
  }

  @override
  void initState() {
    super.initState();

    // Show tutorial after a short delay if this is first connection
    if (widget.showTutorial) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showTutorialOverlay = true;
          });
        }
      });
    }

    setState(() {
      isLoading = false;
    });

    // Load games once on init - will refresh on events only
    _loadUpcomingGames();

    // Sync won bets and show popup if points were won (only for authenticated users)
    if (widget.uid != null) {
      _syncAndShowReward();
    }
  }

  Future<void> _syncAndShowReward() async {
    final appState = context.read<AppState>();
    final result = await appState.syncWonBets();

    if (result != null && result['totalWon'] > 0 && mounted) {
      final totalWon = result['totalWon'] as double;

      // Show reward popup - style Notion
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation1, animation2) {
          return Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.tagYellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.emoji_events_outlined, color: AppColors.warning, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.pointsAdded(double.parse(totalWon.toStringAsFixed(2))),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: logScale(context, 18),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
            child: child,
          );
        },
      );
    }
  }

  Future<void> _loadUpcomingGames() async {
    if (_isRefreshingGames) return; // Prevent concurrent refreshes

    if (!mounted) return;
    setState(() => _isRefreshingGames = true);

    try {
      // Fetch games
      final gamesData = await supabase
          .from('upcoming_scheduled_games')
          .select()
          .order('start_time', ascending: true);

      final games = List<Map<String, dynamic>>.from(gamesData);

      // Extract unique team names and game IDs
      final teamNames = <String>{};
      final gameIds = <dynamic>[];
      for (var game in games) {
        teamNames.add(game['home_team']);
        teamNames.add(game['away_team']);
        gameIds.add(game['id']);
      }

      // Fetch team data and injuries in parallel
      final teamsFuture = teamNames.isNotEmpty
          ? supabase
              .from('teams')
              .select('name, last_games, last10, rank')
              .inFilter('name', teamNames.toList())
          : Future.value(<Map<String, dynamic>>[]);

      final injuriesFuture = gameIds.isNotEmpty
          ? supabase
              .from('gamesdata')
              .select('id, home_injuries, away_injuries')
              .inFilter('id', gameIds)
          : Future.value(<Map<String, dynamic>>[]);

      final results = await Future.wait([teamsFuture, injuriesFuture]);
      final teamsData = List<Map<String, dynamic>>.from(results[0]);
      final injuriesData = List<Map<String, dynamic>>.from(results[1]);

      // Build injuries map: gameId -> {home: count, away: count}
      final injuriesMap = <dynamic, Map<String, int>>{};
      for (var injury in injuriesData) {
        final homeInjuries = injury['home_injuries'] as List<dynamic>? ?? [];
        final awayInjuries = injury['away_injuries'] as List<dynamic>? ?? [];
        injuriesMap[injury['id']] = {
          'home': homeInjuries.length,
          'away': awayInjuries.length,
        };
      }

      // Build team situational data map
      final situationalData = <String, TeamSituationalData>{};
      for (var team in teamsData) {
        situationalData[team['name']] = TeamSituationalData(
          name: team['name'],
          lastGames: team['last_games']?.toString(),
          last10: team['last10']?.toString(),
          rank: team['rank'] is int ? team['rank'] : int.tryParse(team['rank']?.toString() ?? ''),
        );
      }

      if (!mounted) return;
      // Batch setState: update all data together
      setState(() {
        _upcomingGames = games;
        _teamSituationalData = situationalData;
        _gameInjuryCounts = injuriesMap;
        _isRefreshingGames = false;
      });
    } catch (e) {
      debugPrint('Error loading games: $e');
      if (mounted) {
        setState(() => _isRefreshingGames = false);
      }
    }
  }

  Future<void> _addDailyBonus(int points) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final uid = widget.uid;

    // Cannot add daily bonus in preview mode
    if (uid == null) return;

    // Security: Validate user ID
    try {
      SecurityUtils.requireCurrentUser(uid);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.unauthorizedAccess),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Get current user data
      final userData = await supabase
          .from('usersdata')
          .select('points, daily_points_used')
          .eq('id', uid)
          .single();

      if (!mounted) return;

      // Check if daily bonus was already claimed
      final dailyPointsUsed = userData['daily_points_used'] ?? false;

      if (dailyPointsUsed) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(t.dailyPointsTaken),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Add points and mark as used
      final currentPoints = (userData['points'] ?? 0).toDouble();
      final newPoints = currentPoints + points;
      await supabase
          .from('usersdata')
          .update({
            'points': newPoints,
            'daily_points_used': true,
          })
          .eq('id', uid);

      // Sauvegarder dans l'historique des points
      await CacheService.savePointsToHistory(uid, newPoints);

      if (!mounted) return;

      await context.read<AppState>().refreshUserData();
      messenger.showSnackBar(
        SnackBar(
          content: Text(t.pointsAdded(points.toDouble())),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Erreur ajout points quotidiens: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPlayoffBanner(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PlayoffBracketPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A3A5C), Color(0xFF5C1A1A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('\u{1F3C6}', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.playoffEvent.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    loc.playoffBracket,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    loc.pickYourChampion,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.7),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesList() {
    // Show loading state only on initial load (when list is empty and refreshing)
    if (_isRefreshingGames && _upcomingGames.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show empty state if no games after loading
    if (_upcomingGames.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noData,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: logScale(context, 16),
          ),
        ),
      );
    }

    // Get Clock from context for time formatting
    final clock = context.read<Clock>();
    final nowLocal = clock.now();

    // Filter games that haven't started yet and aren't already bet on
    final filteredGames = _upcomingGames.where((game) {
      try {
        final startLocal = clock.toLocalTime(DateTime.parse(game['start_time']).toUtc());
        if (startLocal.isBefore(nowLocal)) return false;
      } catch (_) {
        return false;
      }
      final gameId = game['id'];
      return !betsNotifier.value.any((b) {
        final betGameIds = b['game_id'];
        if (betGameIds is List) {
          return betGameIds.contains(gameId);
        } else {
          return betGameIds == gameId;
        }
      });
    }).toList();

    // Show playoff banner between March 15 and June 30
    final now = DateTime.now();
    final showPlayoffBanner = (now.month == 3 && now.day >= 15) ||
        (now.month >= 4 && now.month <= 6);
    final bannerOffset = showPlayoffBanner ? 1 : 0;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      itemCount: filteredGames.length + bannerOffset,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
      cacheExtent: 500,
      itemBuilder: (context, index) {
        // First item: Playoff bracket banner (only during playoff season)
        if (showPlayoffBanner && index == 0) {
          return _buildPlayoffBanner(context);
        }
        final game = filteredGames[index - bannerOffset];
        final homeTeam = game['home_team'];
        final awayTeam = game['away_team'];
        final homeTeamShort = game['home_team_short'] ?? '';
        final awayTeamShort = game['away_team_short'] ?? '';
        final appState = context.watch<AppState>();
        final oddAway = appState.convertOdds(
          (game['odd_away_team'] as num).toDouble(),
        );
        final oddHome = appState.convertOdds(
          (game['odd_home_team'] as num).toDouble(),
        );

        return Dismissible(
          key: Key(game['id'].toString()),
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: getTeamColor(homeTeam).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 24),
            child: Row(
              children: [
                Icon(Icons.check_rounded, color: getTeamColor(homeTeam), size: 24),
                const SizedBox(width: 8),
                Text(
                  shortNameToCity(homeTeamShort),
                  style: TextStyle(
                    color: getTeamColor(homeTeam),
                    fontSize: logScale(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          secondaryBackground: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: getTeamColor(awayTeam).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  shortNameToCity(awayTeamShort),
                  style: TextStyle(
                    color: getTeamColor(awayTeam),
                    fontSize: logScale(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.check_rounded, color: getTeamColor(awayTeam), size: 24),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            // Preview mode: show auth dialog and block swipe
            if (widget.isPreviewMode) {
              widget.onAuthRequired?.call();
              return false;
            }

            Map<String, dynamic> betToAdd;
            if (direction == DismissDirection.startToEnd) {
              betToAdd = {
                'pickedTeam': homeTeam,
                'odd': game['odd_home_team'],
                'start_time': game['start_time'],
                'game_id': game['id']
              };
            } else {
              betToAdd = {
                'pickedTeam': awayTeam,
                'odd': game['odd_away_team'],
                'start_time': game['start_time'],
                'game_id': game['id']
              };
            }
            bets.add(betToAdd);
            betsNotifier.value = [...betsNotifier.value, betToAdd];
            return true;
          },
          child: FlipCardWidget(
            front: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderDark,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                children: [
                  // En-tête épuré avec date
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.borderDark,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formatGameTime(game['start_time'], clock),
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: logScale(context, 13),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Corps de la carte
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Équipe domicile
                        Expanded(
                          child: _buildTeamCard(
                            context,
                            homeTeam,
                            shortNameToCity(homeTeamShort),
                            oddHome,
                            getTeamColor(homeTeam),
                            getSituationalEmojiWidget(
                              context,
                              homeTeam,
                              getTeamDataWithInjuries(homeTeam, game['id'], true),
                            ),
                          ),
                        ),
                        // VS au centre - style minimaliste
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "vs",
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: logScale(context, 14),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Équipe extérieure
                        Expanded(
                          child: _buildTeamCard(
                            context,
                            awayTeam,
                            shortNameToCity(awayTeamShort),
                            oddAway,
                            getTeamColor(awayTeam),
                            getSituationalEmojiWidget(
                              context,
                              awayTeam,
                              getTeamDataWithInjuries(awayTeam, game['id'], false),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Footer avec instruction - style subtil
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withValues(alpha: 0.5),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.borderDark,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.swipe_outlined,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context)!.slideToBet,
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: logScale(context, 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
            back: GameStatsCard(
              homeTeam: homeTeam,
              awayTeam: awayTeam,
              gameId: game['id'],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
      extendBodyBehindAppBar: !widget.isPreviewMode,
      backgroundColor: AppColors.backgroundDark,
      appBar: widget.isPreviewMode ? null : AppBar(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              Image.asset(
                AppColors.logoAsset,
                height: kToolbarHeight * 0.5,
              ),
              SizedBox(width: kToolbarHeight * 0.15),
              Text(
                "HoopsLeague",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: kToolbarHeight * 0.38,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Only show user actions when authenticated
          if (!widget.isPreviewMode) ...[
            // Daily bonus button - style subtil
            IconButton(
              icon: Icon(Icons.card_giftcard_outlined, color: AppColors.warning),
              onPressed: () => _addDailyBonus(10),
              tooltip: AppLocalizations.of(context)!.dailyPoints,
            ),
            // Refresh button
            IconButton(
              icon: Icon(Icons.refresh_outlined, color: AppColors.textSecondary),
              onPressed: () async {
                final appState = context.read<AppState>();
                await appState.refreshUserData();
              },
              tooltip: AppLocalizations.of(context)!.reloadData,
            ),
          ],
        ],
        iconTheme: IconThemeData(color: AppColors.textSecondary),
      ),
      body: Stack(
        children: [
          // Background - couleur unie style Notion
          Container(
            color: AppColors.backgroundDark,
          ),
          RefreshIndicator(
            onRefresh: () async {
              final appState = widget.isPreviewMode ? null : context.read<AppState>();
              await _loadUpcomingGames();
              if (mounted && appState != null) {
                await appState.refreshUserData();
              }
            },
            color: AppColors.primaryBlue,
            child: SafeArea(
              child: _buildGamesList(),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isPreviewMode
        ? null
        : ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: betsNotifier,
        builder: (context, bets, _) {
          if (bets.isEmpty) return const SizedBox.shrink();

          return Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  MainNavigation.of(context)?.showBucketPage(
                    List<Map<String, dynamic>>.from(bets),
                    onBetPlaced: () => _loadUpcomingGames(),
                    onBetRemoved: (index) {
                      final updatedBets = [...betsNotifier.value];
                      if (index >= 0 && index < updatedBets.length) {
                        updatedBets.removeAt(index);
                        betsNotifier.value = updatedBets;
                      }
                    },
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "${bets.length}",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: logScale(context, 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    ),
    // Tutorial overlay
    if (_showTutorialOverlay)
      TutorialOverlay(
        onComplete: () {
          setState(() {
            _showTutorialOverlay = false;
          });
        },
      ),
      ],
    );
  }

  Widget _buildTeamCard(
    BuildContext context,
    String teamName,
    String teamShort,
    String odd,
    Color teamColor,
    Widget emojiWidget,
  ) {
    return Column(
      children: [
        // Emoji/Image situationnel
        emojiWidget,
        const SizedBox(height: 10),
        // Nom de l'équipe - style Notion
        AutoSizeText(
          teamName,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: logScale(context, 17),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          minFontSize: 10,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Code équipe - subtil
        Text(
          shortNameToCity(teamShort),
          style: TextStyle(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w500,
            fontSize: logScale(context, 12),
          ),
        ),
        const SizedBox(height: 10),
        // Cote - style tag Notion
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: teamColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            odd,
            style: TextStyle(
              color: teamColor,
              fontWeight: FontWeight.w600,
              fontSize: logScale(context, 15),
            ),
          ),
        ),
      ],
    );
  }
}
