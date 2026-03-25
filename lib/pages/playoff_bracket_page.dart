import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

final supabase = Supabase.instance.client;

/// All 30 NBA teams with their full names.
const List<String> allNbaTeams = [
  'Boston Celtics',
  'Brooklyn Nets',
  'Philadelphia 76ers',
  'New York Knicks',
  'Toronto Raptors',
  'Chicago Bulls',
  'Cleveland Cavaliers',
  'Detroit Pistons',
  'Indiana Pacers',
  'Milwaukee Bucks',
  'Atlanta Hawks',
  'Miami Heat',
  'Charlotte Hornets',
  'Orlando Magic',
  'Washington Wizards',
  'Denver Nuggets',
  'Minnesota Timberwolves',
  'Oklahoma City Thunder',
  'Portland Trail Blazers',
  'Utah Jazz',
  'Golden State Warriors',
  'Los Angeles Clippers',
  'Los Angeles Lakers',
  'Phoenix Suns',
  'Sacramento Kings',
  'Dallas Mavericks',
  'Houston Rockets',
  'Memphis Grizzlies',
  'New Orleans Pelicans',
  'San Antonio Spurs',
];

const Map<String, String> teamEmojis = {
  'Celtics': '\u{1F340}',
  'Nets': '\u{1F578}',
  '76ers': '\u{1F514}',
  'Knicks': '\u{1F5FD}',
  'Raptors': '\u{1F996}',
  'Bulls': '\u{1F402}',
  'Cavaliers': '\u{1F6E1}\u{FE0F}',
  'Pistons': '\u{1F527}',
  'Pacers': '\u{1F3C1}',
  'Bucks': '\u{1F98C}',
  'Hawks': '\u{1F985}',
  'Heat': '\u{1F525}',
  'Hornets': '\u{1F41D}',
  'Magic': '\u{1FA84}',
  'Wizards': '\u{1F9D9}',
  'Nuggets': '\u{26CF}\u{FE0F}',
  'Timberwolves': '\u{1F43A}',
  'Thunder': '\u{26A1}',
  'Trail Blazers': '\u{1F332}',
  'Jazz': '\u{1F3B7}',
  'Warriors': '\u{2694}\u{FE0F}',
  'Clippers': '\u{26F5}',
  'Lakers': '\u{1F334}',
  'Suns': '\u{2600}\u{FE0F}',
  'Kings': '\u{1F451}',
  'Mavericks': '🤠',
  'Rockets': '\u{1F680}',
  'Grizzlies': '\u{1F43B}',
  'Pelicans': '🦩',
  'Spurs': '👽',
};

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
  return AppColors.primaryBlue;
}

String getTeamEmoji(String teamName) {
  for (var entry in teamEmojis.entries) {
    if (teamName.contains(entry.key)) return entry.value;
  }
  return '\u{1F3C0}';
}

String getShortName(String teamName) {
  if (teamName.contains('Trail Blazers')) return 'Blazers';
  if (teamName.contains('76ers')) return '76ers';
  return teamName.split(' ').last;
}

/// Conference bracket state.
/// Play-In: slots for seeds 7-10 (editable), plus winner picks.
/// Round 1: slots for seeds 1-6 (editable) + 7th/8th from play-in. Winner picks.
/// Semis/ConfFinals: only qualified teams from previous round.
class ConferenceBracket {
  // Editable seed slots (indices 0-9 = seeds 1-10)
  List<String?> seeds = List.filled(10, null);

  // Play-In winners
  String? playIn7v8Winner;
  String? playIn9v10Winner;
  String? playInFinalWinner;

  // Round 1 winners: [0]: 1v8, [1]: 4v5, [2]: 3v6, [3]: 2v7
  List<String?> round1Winners = List.filled(4, null);

  // Semis winners: [0]: W(1v8) vs W(4v5), [1]: W(3v6) vs W(2v7)
  List<String?> semisWinners = List.filled(2, null);

  // Conf Finals winner
  String? confFinalsWinner;

  /// All teams participating in Round 1 (seeds 1-6 + play-in qualifiers).
  List<String> get round1Teams {
    final teams = <String>[];
    for (int i = 0; i < 6; i++) {
      if (seeds[i] != null) teams.add(seeds[i]!);
    }
    if (playIn7v8Winner != null) teams.add(playIn7v8Winner!);
    if (playInFinalWinner != null) teams.add(playInFinalWinner!);
    return teams;
  }

  /// Teams qualified to Semis = Round 1 winners.
  List<String> get semisQualified =>
      round1Winners.where((t) => t != null).cast<String>().toList();

  /// Teams qualified to Conf Finals = Semis winners.
  List<String> get confFinalsQualified =>
      semisWinners.where((t) => t != null).cast<String>().toList();
}

class PlayoffBracketPage extends StatefulWidget {
  final VoidCallback? onClose;

  const PlayoffBracketPage({super.key, this.onClose});

  @override
  State<PlayoffBracketPage> createState() => _PlayoffBracketPageState();
}

class _PlayoffBracketPageState extends State<PlayoffBracketPage> {
  bool _isLoading = true;

  late ConferenceBracket _east;
  late ConferenceBracket _west;
  String? _finalsWinner;

  @override
  void initState() {
    super.initState();
    _east = ConferenceBracket();
    _west = ConferenceBracket();
    _loadStandings();
  }

  Future<void> _loadStandings() async {
    try {
      final response = await supabase
          .from('teams')
          .select('name, rank')
          .order('rank', ascending: true);

      final teams = List<Map<String, dynamic>>.from(response);

      const eastTeamKeys = [
        'Celtics', 'Nets', '76ers', 'Knicks', 'Raptors',
        'Bulls', 'Cavaliers', 'Pistons', 'Pacers', 'Bucks',
        'Hawks', 'Heat', 'Hornets', 'Magic', 'Wizards',
      ];

      final eastTeams = <Map<String, dynamic>>[];
      final westTeams = <Map<String, dynamic>>[];

      for (final team in teams) {
        final name = team['name'] as String;
        if (eastTeamKeys.any((e) => name.contains(e))) {
          eastTeams.add(team);
        } else {
          westTeams.add(team);
        }
      }

      eastTeams.sort((a, b) => (a['rank'] as int? ?? 99).compareTo(b['rank'] as int? ?? 99));
      westTeams.sort((a, b) => (a['rank'] as int? ?? 99).compareTo(b['rank'] as int? ?? 99));

      if (!mounted) return;
      setState(() {
        // Pre-fill seeds from standings
        for (int i = 0; i < eastTeams.length && i < 10; i++) {
          _east.seeds[i] = eastTeams[i]['name'] as String;
        }
        for (int i = 0; i < westTeams.length && i < 10; i++) {
          _west.seeds[i] = westTeams[i]['name'] as String;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('Error loading standings: $e');
    }
  }

  // ─── Clear downstream when a pick changes ───
  void _clearDownstream(ConferenceBracket conf, String stage, int index) {
    switch (stage) {
      case 'seed':
        // Changing a seed slot: clear everything downstream
        if (index >= 6) {
          // Play-in seed changed → clear play-in and below
          conf.playIn7v8Winner = null;
          conf.playIn9v10Winner = null;
          conf.playInFinalWinner = null;
        }
        conf.round1Winners = List.filled(4, null);
        conf.semisWinners = List.filled(2, null);
        conf.confFinalsWinner = null;
        _finalsWinner = null;
        break;
      case 'playIn7v8':
        conf.playInFinalWinner = null;
        conf.round1Winners[3] = null; // 2v7
        conf.round1Winners[0] = null; // 1v8
        _clearDownstream(conf, 'round1', 3);
        _clearDownstream(conf, 'round1', 0);
        break;
      case 'playIn9v10':
        conf.playInFinalWinner = null;
        conf.round1Winners[0] = null;
        _clearDownstream(conf, 'round1', 0);
        break;
      case 'playInFinal':
        conf.round1Winners[0] = null;
        _clearDownstream(conf, 'round1', 0);
        break;
      case 'round1':
        final semisIdx = index ~/ 2;
        conf.semisWinners[semisIdx] = null;
        _clearDownstream(conf, 'semis', semisIdx);
        break;
      case 'semis':
        conf.confFinalsWinner = null;
        _finalsWinner = null;
        break;
      case 'confFinals':
        _finalsWinner = null;
        break;
    }
  }

  void _onSeedChanged(ConferenceBracket conf, int seedIndex, String team) {
    setState(() {
      conf.seeds[seedIndex] = team;
      _clearDownstream(conf, 'seed', seedIndex);
    });
  }

  void _onWinnerSelected(ConferenceBracket conf, String stage, int index, String team) {
    setState(() {
      switch (stage) {
        case 'playIn7v8':
          if (conf.playIn7v8Winner == team) return;
          conf.playIn7v8Winner = team;
          _clearDownstream(conf, stage, index);
          break;
        case 'playIn9v10':
          if (conf.playIn9v10Winner == team) return;
          conf.playIn9v10Winner = team;
          _clearDownstream(conf, stage, index);
          break;
        case 'playInFinal':
          if (conf.playInFinalWinner == team) return;
          conf.playInFinalWinner = team;
          _clearDownstream(conf, stage, index);
          break;
        case 'round1':
          if (conf.round1Winners[index] == team) return;
          conf.round1Winners[index] = team;
          _clearDownstream(conf, stage, index);
          break;
        case 'semis':
          if (conf.semisWinners[index] == team) return;
          conf.semisWinners[index] = team;
          _clearDownstream(conf, stage, index);
          break;
        case 'confFinals':
          if (conf.confFinalsWinner == team) return;
          conf.confFinalsWinner = team;
          _clearDownstream(conf, stage, index);
          break;
        case 'finals':
          _finalsWinner = team;
          break;
      }
    });
  }

  void _resetBracket() {
    setState(() {
      // Keep seeds, reset all picks
      _east.playIn7v8Winner = null;
      _east.playIn9v10Winner = null;
      _east.playInFinalWinner = null;
      _east.round1Winners = List.filled(4, null);
      _east.semisWinners = List.filled(2, null);
      _east.confFinalsWinner = null;
      _west.playIn7v8Winner = null;
      _west.playIn9v10Winner = null;
      _west.playInFinalWinner = null;
      _west.round1Winners = List.filled(4, null);
      _west.semisWinners = List.filled(2, null);
      _west.confFinalsWinner = null;
      _finalsWinner = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.bracketReset),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Show a bottom sheet to pick a team.
  /// [allowedTeams] filters the list (null = all 30 teams).
  Future<String?> _showTeamPicker({List<String>? allowedTeams}) async {
    final teams = allowedTeams ?? allNbaTeams;
    if (teams.isEmpty) return null;

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    AppLocalizations.of(context)!.selectWinner,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: teams.length,
                    itemBuilder: (ctx, i) {
                      final team = teams[i];
                      final emoji = getTeamEmoji(team);
                      final color = getTeamColor(team);
                      final shortName = getShortName(team);

                      return InkWell(
                        onTap: () => Navigator.pop(ctx, team),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(emoji, style: const TextStyle(fontSize: 20)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  shortName,
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                team.replaceAll(shortName, '').trim(),
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.appBar,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (widget.onClose != null) {
              widget.onClose!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Row(
          children: [
            const Text('\u{1F3C6}', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              loc.playoffBracket,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: _resetBracket,
            tooltip: loc.bracketReset,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accentPrimary))
          : _buildBracketContent(loc),
    );
  }

  Widget _buildBracketContent(AppLocalizations loc) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              loc.playoffBracketSubtitle,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          if (_finalsWinner != null) _buildChampionBanner(loc),
          const SizedBox(height: 8),
          _buildConferenceSection(loc, loc.eastConference, _east, isEast: true),
          const SizedBox(height: 12),
          _buildFinalsSection(loc),
          const SizedBox(height: 12),
          _buildConferenceSection(loc, loc.westConference, _west, isEast: false),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Champion Banner ───
  Widget _buildChampionBanner(AppLocalizations loc) {
    final team = _finalsWinner!;
    final color = getTeamColor(team);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.4)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('\u{1F3C6}', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              children: [
                Text(
                  loc.champion.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${getTeamEmoji(team)} ${getShortName(team)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Text('\u{1F3C6}', style: TextStyle(fontSize: 28)),
        ],
      ),
    );
  }

  // ─── Conference Section ───
  Widget _buildConferenceSection(
    AppLocalizations loc,
    String confName,
    ConferenceBracket conf, {
    required bool isEast,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: AppColors.cardDecoration(borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isEast ? const Color(0xFF1A3A5C) : const Color(0xFF5C1A1A),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text(
                  isEast ? '\u{1F7E6}' : '\u{1F7E5}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  confName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          // Bracket (horizontal scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlayInColumn(loc, conf),
                _buildArrow(),
                _buildRound1Column(loc, conf),
                _buildArrow(),
                _buildSemisColumn(loc, conf),
                _buildArrow(),
                _buildConfFinalsColumn(loc, conf),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
        ],
      ),
    );
  }

  Widget _buildStageLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ─── Play-In Column ───
  Widget _buildPlayInColumn(AppLocalizations loc, ConferenceBracket conf) {
    final seed7 = conf.seeds[6];
    final seed8 = conf.seeds[7];
    final seed9 = conf.seeds[8];
    final seed10 = conf.seeds[9];

    // Loser of 7v8
    final loser7v8 = (conf.playIn7v8Winner != null && seed7 != null && seed8 != null)
        ? (conf.playIn7v8Winner == seed7 ? seed8 : seed7)
        : null;

    return Column(
      children: [
        _buildStageLabel(loc.playIn),
        // 7 vs 8
        _buildMatchupCard(
          teamA: seed7,
          seedA: 7,
          teamB: seed8,
          seedB: 8,
          winner: conf.playIn7v8Winner,
          onSelectTeamA: () => _pickSeed(conf, 6),
          onSelectTeamB: () => _pickSeed(conf, 7),
          onPickWinner: (team) => _onWinnerSelected(conf, 'playIn7v8', 0, team),
          subtitle: '\u{2192} #7',
        ),
        const SizedBox(height: 8),
        // 9 vs 10
        _buildMatchupCard(
          teamA: seed9,
          seedA: 9,
          teamB: seed10,
          seedB: 10,
          winner: conf.playIn9v10Winner,
          onSelectTeamA: () => _pickSeed(conf, 8),
          onSelectTeamB: () => _pickSeed(conf, 9),
          onPickWinner: (team) => _onWinnerSelected(conf, 'playIn9v10', 0, team),
          subtitle: '\u{2192} Play-In',
        ),
        const SizedBox(height: 8),
        // Play-In final: loser 7v8 vs winner 9v10
        if (loser7v8 != null && conf.playIn9v10Winner != null)
          _buildMatchupCard(
            teamA: loser7v8,
            teamB: conf.playIn9v10Winner!,
            winner: conf.playInFinalWinner,
            onPickWinner: (team) => _onWinnerSelected(conf, 'playInFinal', 0, team),
            subtitle: '\u{2192} #8',
          )
        else
          _buildEmptySlot('\u{2192} #8'),
      ],
    );
  }

  // ─── Round 1 Column ───
  Widget _buildRound1Column(AppLocalizations loc, ConferenceBracket conf) {
    final seed1 = conf.seeds[0];
    final seed2 = conf.seeds[1];
    final seed3 = conf.seeds[2];
    final seed4 = conf.seeds[3];
    final seed5 = conf.seeds[4];
    final seed6 = conf.seeds[5];
    final seed7 = conf.playIn7v8Winner;
    final seed8 = conf.playInFinalWinner;

    return Column(
      children: [
        _buildStageLabel(loc.firstRound),
        // 1 vs 8
        _buildMatchupCard(
          teamA: seed1,
          seedA: 1,
          teamB: seed8,
          seedB: 8,
          winner: conf.round1Winners[0],
          onSelectTeamA: () => _pickSeed(conf, 0),
          onPickWinner: (seed8 != null && seed1 != null)
              ? (team) => _onWinnerSelected(conf, 'round1', 0, team)
              : null,
        ),
        const SizedBox(height: 8),
        // 4 vs 5
        _buildMatchupCard(
          teamA: seed4,
          seedA: 4,
          teamB: seed5,
          seedB: 5,
          winner: conf.round1Winners[1],
          onSelectTeamA: () => _pickSeed(conf, 3),
          onSelectTeamB: () => _pickSeed(conf, 4),
          onPickWinner: (seed4 != null && seed5 != null)
              ? (team) => _onWinnerSelected(conf, 'round1', 1, team)
              : null,
        ),
        const SizedBox(height: 8),
        // 3 vs 6
        _buildMatchupCard(
          teamA: seed3,
          seedA: 3,
          teamB: seed6,
          seedB: 6,
          winner: conf.round1Winners[2],
          onSelectTeamA: () => _pickSeed(conf, 2),
          onSelectTeamB: () => _pickSeed(conf, 5),
          onPickWinner: (seed3 != null && seed6 != null)
              ? (team) => _onWinnerSelected(conf, 'round1', 2, team)
              : null,
        ),
        const SizedBox(height: 8),
        // 2 vs 7
        _buildMatchupCard(
          teamA: seed2,
          seedA: 2,
          teamB: seed7,
          seedB: 7,
          winner: conf.round1Winners[3],
          onSelectTeamA: () => _pickSeed(conf, 1),
          onPickWinner: (seed2 != null && seed7 != null)
              ? (team) => _onWinnerSelected(conf, 'round1', 3, team)
              : null,
        ),
      ],
    );
  }

  // ─── Semis Column ───
  Widget _buildSemisColumn(AppLocalizations loc, ConferenceBracket conf) {
    final w0 = conf.round1Winners[0]; // winner 1v8
    final w1 = conf.round1Winners[1]; // winner 4v5
    final w2 = conf.round1Winners[2]; // winner 3v6
    final w3 = conf.round1Winners[3]; // winner 2v7

    return Column(
      children: [
        _buildStageLabel(loc.confSemis),
        if (w0 != null && w1 != null)
          _buildMatchupCard(
            teamA: w0,
            teamB: w1,
            winner: conf.semisWinners[0],
            onPickWinner: (team) => _onWinnerSelected(conf, 'semis', 0, team),
          )
        else
          _buildEmptySlot(null),
        const SizedBox(height: 8),
        if (w2 != null && w3 != null)
          _buildMatchupCard(
            teamA: w2,
            teamB: w3,
            winner: conf.semisWinners[1],
            onPickWinner: (team) => _onWinnerSelected(conf, 'semis', 1, team),
          )
        else
          _buildEmptySlot(null),
      ],
    );
  }

  // ─── Conf Finals Column ───
  Widget _buildConfFinalsColumn(AppLocalizations loc, ConferenceBracket conf) {
    final a = conf.semisWinners[0];
    final b = conf.semisWinners[1];

    return Column(
      children: [
        _buildStageLabel(loc.confFinals),
        if (a != null && b != null)
          _buildMatchupCard(
            teamA: a,
            teamB: b,
            winner: conf.confFinalsWinner,
            onPickWinner: (team) => _onWinnerSelected(conf, 'confFinals', 0, team),
          )
        else
          _buildEmptySlot(null),
      ],
    );
  }

  // ─── Finals Section ───
  Widget _buildFinalsSection(AppLocalizations loc) {
    final eastChamp = _east.confFinalsWinner;
    final westChamp = _west.confFinalsWinner;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentPrimary.withValues(alpha: 0.1),
            AppColors.accentSecondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentPrimary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            '\u{1F3C6} ${loc.finals.toUpperCase()} \u{1F3C6}',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          if (eastChamp != null && westChamp != null)
            _buildMatchupCard(
              teamA: eastChamp,
              teamB: westChamp,
              winner: _finalsWinner,
              onPickWinner: (team) {
                setState(() => _finalsWinner = team);
              },
              isFinale: true,
            )
          else
            _buildEmptySlot(loc.pickYourChampion),
        ],
      ),
    );
  }

  // ─── Pick a seed (opens team picker with all 30 teams) ───
  Future<void> _pickSeed(ConferenceBracket conf, int seedIndex) async {
    final picked = await _showTeamPicker();
    if (picked != null && mounted) {
      _onSeedChanged(conf, seedIndex, picked);
    }
  }

  // ─── Matchup Card ───
  Widget _buildMatchupCard({
    String? teamA,
    int? seedA,
    String? teamB,
    int? seedB,
    String? winner,
    VoidCallback? onSelectTeamA,
    VoidCallback? onSelectTeamB,
    void Function(String)? onPickWinner,
    String? subtitle,
    bool isFinale = false,
  }) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFinale
              ? AppColors.accentPrimary.withValues(alpha: 0.4)
              : AppColors.borderDark,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildTeamRow(
            team: teamA,
            seed: seedA,
            isSelected: winner != null && winner == teamA,
            isTop: true,
            onTapTeam: onSelectTeamA,
            onTapWinner: (teamA != null && teamB != null && onPickWinner != null)
                ? () => onPickWinner(teamA)
                : null,
          ),
          Container(height: 1, color: AppColors.borderDark),
          _buildTeamRow(
            team: teamB,
            seed: seedB,
            isSelected: winner != null && winner == teamB,
            isTop: false,
            onTapTeam: onSelectTeamB,
            onTapWinner: (teamA != null && teamB != null && onPickWinner != null)
                ? () => onPickWinner(teamB)
                : null,
          ),
          if (subtitle != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceHover,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(9)),
              ),
              child: Text(
                subtitle,
                style: TextStyle(color: AppColors.textTertiary, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamRow({
    String? team,
    int? seed,
    required bool isSelected,
    required bool isTop,
    VoidCallback? onTapTeam,
    VoidCallback? onTapWinner,
  }) {
    if (team == null) {
      return GestureDetector(
        onTap: onTapTeam,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: isTop ? const Radius.circular(9) : Radius.zero,
              bottom: !isTop ? const Radius.circular(9) : Radius.zero,
            ),
          ),
          child: Row(
            children: [
              if (seed != null) ...[
                _buildSeedBadge(seed),
                const SizedBox(width: 6),
              ],
              Text(
                '?',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Spacer(),
              if (onTapTeam != null)
                Icon(Icons.edit, color: AppColors.textTertiary, size: 14),
            ],
          ),
        ),
      );
    }

    final color = getTeamColor(team);
    final emoji = getTeamEmoji(team);
    final shortName = getShortName(team);

    return GestureDetector(
      onTap: onTapWinner,
      onLongPress: onTapTeam,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.vertical(
            top: isTop ? const Radius.circular(9) : Radius.zero,
            bottom: !isTop ? const Radius.circular(9) : Radius.zero,
          ),
        ),
        child: Row(
          children: [
            if (seed != null) ...[
              _buildSeedBadge(seed),
              const SizedBox(width: 4),
            ],
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                shortName,
                style: TextStyle(
                  color: isSelected ? color : AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 16),
            if (onTapTeam != null && !isSelected)
              Icon(Icons.swap_horiz, color: AppColors.textTertiary, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSeedBadge(int seed) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$seed',
        style: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptySlot(String? label) {
    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Text(
        label ?? '?',
        style: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 11,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
