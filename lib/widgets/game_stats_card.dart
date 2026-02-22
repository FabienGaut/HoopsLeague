import 'package:flutter/material.dart';
import 'package:hoopsleague/theme/app_colors.dart';
import 'package:hoopsleague/theme/utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

final supabase = Supabase.instance.client;

class GameStatsCard extends StatefulWidget {
  final String homeTeam;
  final String awayTeam;
  final dynamic gameId;

  const GameStatsCard({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.gameId,
  });

  @override
  State<GameStatsCard> createState() => _GameStatsCardState();
}

class _GameStatsCardState extends State<GameStatsCard> {
  bool _isLoading = true;
  String? _error;
  
  Map<String, dynamic>? _homeTeamData;
  Map<String, dynamic>? _awayTeamData;
  List<dynamic>? _homeInjuries;
  List<dynamic>? _awayInjuries;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch team data from teams table
      final teamsResponse = await supabase
          .from('teams')
          .select('name, last_games, player1_stats')
          .or('name.eq.${widget.homeTeam},name.eq.${widget.awayTeam}');

      // Fetch injury data from gamesdata table
      final injuriesResponse = await supabase
          .from('gamesdata')
          .select('home_injuries, away_injuries')
          .eq('id', widget.gameId)
          .maybeSingle();

      // Parse team data
      for (var team in teamsResponse) {
        if (team['name'] == widget.homeTeam) {
          _homeTeamData = team;
        } else if (team['name'] == widget.awayTeam) {
          _awayTeamData = team;
        }
      }

      // Parse injury data
      if (injuriesResponse != null) {
        _homeInjuries = injuriesResponse['home_injuries'] as List<dynamic>?;
        _awayInjuries = injuriesResponse['away_injuries'] as List<dynamic>?;
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: _isLoading
            ? _buildLoadingState()
            : _error != null
                ? _buildErrorState()
                : _buildStatsContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 400,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryBlue),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.loading,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: logScale(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 400,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.errorLoadingStats,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: logScale(context, 16),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? '',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: logScale(context, 12),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header - style Notion
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
                  Icons.bar_chart_outlined,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.teamStatistics,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: logScale(context, 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.tapToFlipBack,
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: logScale(context, 11),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Team stats comparison
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTeamStats(
                        widget.homeTeam,
                        _homeTeamData,
                        true,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: AppColors.borderDark,
                    ),
                    Expanded(
                      child: _buildTeamStats(
                        widget.awayTeam,
                        _awayTeamData,
                        false,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Injuries section
                _buildInjuriesSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStats(String teamName, Map<String, dynamic>? teamData, bool isHome) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Team name
        Text(
          _getShortTeamName(teamName),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: logScale(context, 14),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),

        // Last games
        if (teamData != null && teamData['last_games'] != null)
          _buildLastGames(teamData['last_games']),

        const SizedBox(height: 12),

        // Player stats
        if (teamData != null && teamData['player1_stats'] != null)
          _buildPlayerStats(teamData['player1_stats']),
      ],
    );
  }

  Widget _buildLastGames(dynamic lastGames) {
    // last_games is a string of 5 characters containing W (win) and L (loss)
    // Example: "WLWWL"
    String gamesString = '';

    if (lastGames is String) {
      gamesString = lastGames;
    } else if (lastGames is List && lastGames.isNotEmpty) {
      gamesString = lastGames.join('');
    } else {
      return const SizedBox.shrink();
    }

    // Convert string to list of characters
    final gamesList = gamesString.toUpperCase().split('').take(5).toList();

    if (gamesList.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.lastGames,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: logScale(context, 11),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: gamesList.map((game) {
              final isWin = game == 'W';
              final displayText = isWin
                  ? AppLocalizations.of(context)!.win
                  : AppLocalizations.of(context)!.loss;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isWin ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isWin ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Text(
                  displayText,
                  style: TextStyle(
                    color: isWin ? Colors.green : Colors.red,
                    fontSize: logScale(context, 10),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStats(dynamic playerStats) {
    // Handle JSONB format - could be object or array
    Map<String, dynamic> stats = {};

    if (playerStats is Map) {
      stats = Map<String, dynamic>.from(playerStats);
    } else if (playerStats is List && playerStats.isNotEmpty) {
      stats = Map<String, dynamic>.from(playerStats[0]);
    }

    if (stats.isEmpty) return const SizedBox.shrink();

    // Extract player name if it exists
    final playerName = stats['name'] ?? stats['player_name'] ?? stats['player'];

    // Filter out name fields to only show stats
    final statsOnly = Map<String, dynamic>.from(stats);
    statsOnly.remove('name');
    statsOnly.remove('player_name');
    statsOnly.remove('player');

    // Order stats: PPG first, then APG, then others
    final orderedStats = <MapEntry<String, dynamic>>[];

    // Priority order for stats
    final priorityKeys = ['ppg', 'PPG', 'apg', 'APG'];

    // Add priority stats first
    for (var key in priorityKeys) {
      if (statsOnly.containsKey(key)) {
        orderedStats.add(MapEntry(key, statsOnly[key]));
        statsOnly.remove(key);
      }
    }

    // Add remaining stats
    orderedStats.addAll(statsOnly.entries);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Player name - style Notion
          if (playerName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                playerName.toString(),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: logScale(context, 12),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          // Stats - style minimaliste
          ...orderedStats.take(3).map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: logScale(context, 10),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    entry.value.toString(),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: logScale(context, 12),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInjuriesSection() {
    final hasHomeInjuries = _homeInjuries != null && _homeInjuries!.isNotEmpty;
    final hasAwayInjuries = _awayInjuries != null && _awayInjuries!.isNotEmpty;

    if (!hasHomeInjuries && !hasAwayInjuries) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.noInjuries,
              style: TextStyle(
                color: Colors.green,
                fontSize: logScale(context, 13),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.medical_services_outlined,
              color: Colors.red[400],
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.injuredPlayers,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: logScale(context, 14),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Two columns for injuries
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Home team injuries (left column)
            Expanded(
              child: hasHomeInjuries
                  ? _buildInjuryList(widget.homeTeam, _homeInjuries!)
                  : Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getShortTeamName(widget.homeTeam),
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: logScale(context, 12),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Away team injuries (right column)
            Expanded(
              child: hasAwayInjuries
                  ? _buildInjuryList(widget.awayTeam, _awayInjuries!)
                  : Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getShortTeamName(widget.awayTeam),
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: logScale(context, 12),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInjuryList(String teamName, List<dynamic> injuries) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getShortTeamName(teamName),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: logScale(context, 12),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...injuries.map((injury) {
            String playerName = '';
            String injuryInfo = '';

            if (injury is Map) {
              playerName = injury['name']?.toString() ?? injury['player']?.toString() ?? AppLocalizations.of(context)!.unknownUser;
              injuryInfo = injury['injury']?.toString() ?? injury['status']?.toString() ?? '';
            } else {
              playerName = injury.toString();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.person_off,
                    color: Colors.red[300],
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      injuryInfo.isNotEmpty ? '$playerName ($injuryInfo)' : playerName,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: logScale(context, 11),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getShortTeamName(String fullName) {
    // Extract just the team name (e.g., "Boston Celtics" -> "Celtics")
    final parts = fullName.split(' ');
    return parts.isNotEmpty ? parts.last : fullName;
  }
}
