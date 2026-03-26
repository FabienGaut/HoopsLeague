import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

final supabase = Supabase.instance.client;
const String _currentSeason = '2025-2026';

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

  Map<String, dynamic> toJson() => {
    'seeds': seeds,
    'playIn7v8Winner': playIn7v8Winner,
    'playIn9v10Winner': playIn9v10Winner,
    'playInFinalWinner': playInFinalWinner,
    'round1Winners': round1Winners,
    'semisWinners': semisWinners,
    'confFinalsWinner': confFinalsWinner,
  };

  void loadFromJson(Map<String, dynamic> json) {
    seeds = List<String?>.from(json['seeds'] ?? List.filled(10, null));
    playIn7v8Winner = json['playIn7v8Winner'] as String?;
    playIn9v10Winner = json['playIn9v10Winner'] as String?;
    playInFinalWinner = json['playInFinalWinner'] as String?;
    round1Winners = List<String?>.from(json['round1Winners'] ?? List.filled(4, null));
    semisWinners = List<String?>.from(json['semisWinners'] ?? List.filled(2, null));
    confFinalsWinner = json['confFinalsWinner'] as String?;
  }
}

class PlayoffBracketPage extends StatefulWidget {
  final VoidCallback? onClose;

  const PlayoffBracketPage({super.key, this.onClose});

  @override
  State<PlayoffBracketPage> createState() => _PlayoffBracketPageState();
}

class _PlayoffBracketPageState extends State<PlayoffBracketPage> with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isSaving = false;

  late ConferenceBracket _east;
  late ConferenceBracket _west;
  String? _finalsWinner;

  // League & persistence state
  List<Map<String, dynamic>> _userLeagues = [];
  Map<String, dynamic>? _selectedLeague;
  bool _isValidated = false;

  // Default seeds from standings (used when no saved bracket)
  final List<String?> _defaultEastSeeds = List.filled(10, null);
  final List<String?> _defaultWestSeeds = List.filled(10, null);

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _championController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _championScale;

  // Bounce animation for winner selection
  late AnimationController _bounceController;

  /// Calculate bracket completion progress (0.0 to 1.0)
  double get _progress {
    int total = 0;
    int filled = 0;

    for (final conf in [_east, _west]) {
      // Play-In winners: 3 per conference
      total += 3;
      if (conf.playIn7v8Winner != null) filled++;
      if (conf.playIn9v10Winner != null) filled++;
      if (conf.playInFinalWinner != null) filled++;

      // Round 1 winners: 4 per conference
      total += 4;
      for (final w in conf.round1Winners) {
        if (w != null) filled++;
      }

      // Semis winners: 2 per conference
      total += 2;
      for (final w in conf.semisWinners) {
        if (w != null) filled++;
      }

      // Conf Finals winner: 1 per conference
      total += 1;
      if (conf.confFinalsWinner != null) filled++;
    }

    // Finals winner
    total += 1;
    if (_finalsWinner != null) filled++;

    return total == 0 ? 0.0 : filled / total;
  }

  int get _filledCount {
    int filled = 0;
    for (final conf in [_east, _west]) {
      if (conf.playIn7v8Winner != null) filled++;
      if (conf.playIn9v10Winner != null) filled++;
      if (conf.playInFinalWinner != null) filled++;
      for (final w in conf.round1Winners) { if (w != null) filled++; }
      for (final w in conf.semisWinners) { if (w != null) filled++; }
      if (conf.confFinalsWinner != null) filled++;
    }
    if (_finalsWinner != null) filled++;
    return filled;
  }

  int get _totalCount => 21; // 3+4+2+1 per conference (x2) + 1 finals

  @override
  void initState() {
    super.initState();
    _east = ConferenceBracket();
    _west = ConferenceBracket();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _championController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _championScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _championController, curve: Curves.elasticOut),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _loadInitialData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _championController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadStandings();
    await _loadUserLeagues();
  }

  Future<void> _loadUserLeagues() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final userData = await supabase
          .from('usersdata')
          .select('leagues')
          .eq('id', userId)
          .maybeSingle();

      if (userData == null || userData['leagues'] == null) return;

      final leagueIds = List<String>.from(userData['leagues'] ?? []);
      if (leagueIds.isEmpty) return;

      final leagues = await supabase
          .from('leagues')
          .select('id, name')
          .inFilter('id', leagueIds);

      if (!mounted) return;
      setState(() {
        _userLeagues = List<Map<String, dynamic>>.from(leagues);
        // Auto-select first league
        if (_userLeagues.isNotEmpty) {
          _selectedLeague = _userLeagues.first;
          _loadBracketFromDb();
        }
      });
    } catch (e) {
      debugPrint('Error loading leagues: $e');
    }
  }

  Future<void> _loadBracketFromDb() async {
    if (_selectedLeague == null) return;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final result = await supabase
          .from('brackets')
          .select()
          .eq('user_id', userId)
          .eq('league_id', _selectedLeague!['id'])
          .eq('season', _currentSeason)
          .maybeSingle();

      if (!mounted) return;
      if (result != null) {
        final data = result['bracket_data'] as Map<String, dynamic>;
        setState(() {
          _east.loadFromJson(data['east'] as Map<String, dynamic>? ?? {});
          _west.loadFromJson(data['west'] as Map<String, dynamic>? ?? {});
          _finalsWinner = data['finals_winner'] as String?;
          _isValidated = result['is_validated'] as bool? ?? false;
        });
      } else {
        // No saved bracket: reset to default seeds
        setState(() {
          _east = ConferenceBracket();
          _west = ConferenceBracket();
          for (int i = 0; i < 10; i++) {
            _east.seeds[i] = _defaultEastSeeds[i];
            _west.seeds[i] = _defaultWestSeeds[i];
          }
          _finalsWinner = null;
          _isValidated = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading bracket: $e');
    }
  }

  Future<void> _saveBracket() async {
    if (_selectedLeague == null || _isValidated || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final bracketData = {
        'east': _east.toJson(),
        'west': _west.toJson(),
        'finals_winner': _finalsWinner,
      };

      debugPrint('Saving bracket for league: ${_selectedLeague!['id']}');
      debugPrint('Bracket data: $bracketData');

      final result = await supabase.rpc('save_bracket', params: {
        'p_league_id': _selectedLeague!['id'],
        'p_bracket_data': bracketData,
        'p_season': _currentSeason,
      });

      debugPrint('Save result: $result');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.bracketSaved),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e, stack) {
      debugPrint('Error saving bracket: $e');
      debugPrint('Stack: $stack');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _validateBracket() async {
    if (_selectedLeague == null || _isValidated) return;
    final loc = AppLocalizations.of(context)!;

    if (_finalsWinner == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.bracketIncomplete)),
      );
      return;
    }

    // Save first, then validate
    await _saveBracket();

    try {
      await supabase.rpc('validate_bracket', params: {
        'p_league_id': _selectedLeague!['id'],
        'p_season': _currentSeason,
      });

      if (!mounted) return;
      setState(() => _isValidated = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.bracketValidated),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showCompareBrackets() async {
    if (_selectedLeague == null) return;

    try {
      final result = await supabase.rpc('get_league_brackets', params: {
        'p_league_id': _selectedLeague!['id'],
        'p_season': _currentSeason,
      });

      if (!mounted) return;
      final brackets = result is List ? List<Map<String, dynamic>>.from(result) : <Map<String, dynamic>>[];

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _LeagueBracketsPage(
            leagueName: _selectedLeague!['name'] as String,
            brackets: brackets,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
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
        for (int i = 0; i < eastTeams.length && i < 10; i++) {
          _defaultEastSeeds[i] = eastTeams[i]['name'] as String;
          _east.seeds[i] = eastTeams[i]['name'] as String;
        }
        for (int i = 0; i < westTeams.length && i < 10; i++) {
          _defaultWestSeeds[i] = westTeams[i]['name'] as String;
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
    if (_isValidated) return;
    setState(() {
      conf.seeds[seedIndex] = team;
      _clearDownstream(conf, 'seed', seedIndex);
    });
  }

  void _onWinnerSelected(ConferenceBracket conf, String stage, int index, String team) {
    if (_isValidated) return;
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
          _championController.forward(from: 0);
          break;
      }
    });
  }

  void _resetBracket() {
    if (_isValidated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.bracketAlreadyValidated)),
      );
      return;
    }
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
          if (!_isValidated)
            IconButton(
              icon: Icon(Icons.refresh, color: AppColors.textSecondary),
              onPressed: _resetBracket,
              tooltip: loc.bracketReset,
            ),
          if (_selectedLeague != null)
            IconButton(
              icon: Icon(Icons.people, color: AppColors.textSecondary),
              onPressed: _showCompareBrackets,
              tooltip: loc.compareBrackets,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accentPrimary))
          : _buildBracketContent(loc),
    );
  }

  Widget _buildLeagueSelector(AppLocalizations loc) {
    if (_userLeagues.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLeague?['id'] as String?,
          isExpanded: true,
          dropdownColor: AppColors.surfaceElevated,
          hint: Text(loc.selectLeague, style: TextStyle(color: AppColors.textTertiary)),
          icon: Icon(Icons.expand_more, color: AppColors.textSecondary),
          items: _userLeagues.map((league) {
            return DropdownMenuItem<String>(
              value: league['id'] as String,
              child: Text(
                league['name'] as String,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (leagueId) {
            final league = _userLeagues.firstWhere((l) => l['id'] == leagueId);
            setState(() => _selectedLeague = league);
            _loadBracketFromDb();
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isValidated
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isValidated
              ? Colors.green.withValues(alpha: 0.4)
              : Colors.orange.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isValidated ? Icons.lock : Icons.edit_note,
            size: 16,
            color: _isValidated ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            _isValidated ? loc.bracketLocked : loc.bracketDraft,
            style: TextStyle(
              color: _isValidated ? Colors.green : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations loc) {
    if (_selectedLeague == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          if (!_isValidated) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveBracket,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save, size: 18),
                label: Text(loc.saveBracket),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _validateBracket,
                icon: const Icon(Icons.check_circle, size: 18),
                label: Text(loc.validateBracket, textAlign: TextAlign.center),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
          if (_isValidated)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showCompareBrackets,
                icon: const Icon(Icons.people, size: 18),
                label: Text(loc.compareBrackets),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _progress;
    final filled = _filledCount;
    final total = _totalCount;
    final percentage = (progress * 100).round();

    Color progressColor;
    String emoji;
    if (percentage == 100) {
      progressColor = AppColors.success;
      emoji = '\u{1F3C6}';
    } else if (percentage >= 75) {
      progressColor = const Color(0xFF2383E2);
      emoji = '\u{1F525}';
    } else if (percentage >= 50) {
      progressColor = AppColors.accentSecondary;
      emoji = '\u{1F4AA}';
    } else if (percentage >= 25) {
      progressColor = AppColors.warning;
      emoji = '\u{1F3C0}';
    } else {
      progressColor = AppColors.textTertiary;
      emoji = '\u{1F449}';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$filled / $total picks',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: progressColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                // Background
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHover,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                // Fill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  height: 8,
                  width: (MediaQuery.of(context).size.width - 64) * progress.clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [progressColor, progressColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          _buildLeagueSelector(loc),
          if (_selectedLeague != null) ...[
            const SizedBox(height: 4),
            _buildProgressBar(),
            _buildStatusBadge(loc),
            _buildActionButtons(loc),
          ],
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

    return ScaleTransition(
      scale: _championScale,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // Background gradient
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.9),
                      color.withValues(alpha: 0.6),
                      color.withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('\u{1F3C6}', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Column(
                        children: [
                          Text(
                            loc.champion.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${getTeamEmoji(team)} ${getShortName(team)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('\u{1F3C6}', style: TextStyle(fontSize: 32)),
                  ],
                ),
              ),
              // Sparkle overlay
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _SparklePainter(
                        progress: _pulseAnimation.value,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isEast
                    ? [const Color(0xFF1A3A5C), const Color(0xFF244B6E)]
                    : [const Color(0xFF5C1A1A), const Color(0xFF6E2424)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isEast ? '\u{1F7E6}' : '\u{1F7E5}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  confName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                if (conf.confFinalsWinner != null) ...[
                  Text(
                    '${getTeamEmoji(conf.confFinalsWinner!)} ${getShortName(conf.confFinalsWinner!)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('\u{1F451}', style: TextStyle(fontSize: 14)),
                ],
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
                _buildConnector(),
                _buildRound1Column(loc, conf),
                _buildConnector(),
                _buildSemisColumn(loc, conf),
                _buildConnector(),
                _buildConfFinalsColumn(loc, conf),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        children: [
          const SizedBox(height: 40),
          SizedBox(
            width: 24,
            height: 20,
            child: CustomPaint(
              painter: _BracketConnectorPainter(
                color: AppColors.borderDark,
                accentColor: AppColors.accentPrimary.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageLabel(String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
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
            onPickWinner: _isValidated ? null : (team) => _onWinnerSelected(conf, 'confFinals', 0, team),
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

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentPrimary.withValues(alpha: 0.06 + 0.04 * _pulseAnimation.value),
                AppColors.accentSecondary.withValues(alpha: 0.06 + 0.04 * _pulseAnimation.value),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accentPrimary.withValues(alpha: 0.2 + 0.15 * _pulseAnimation.value),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPrimary.withValues(alpha: 0.05 + 0.03 * _pulseAnimation.value),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('\u{1F3C6}', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    loc.finals.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('\u{1F3C6}', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'East vs West',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              if (eastChamp != null && westChamp != null)
                Center(
                  child: _buildMatchupCard(
                    teamA: eastChamp,
                    teamB: westChamp,
                    winner: _finalsWinner,
                    onPickWinner: _isValidated ? null : (team) {
                      _onWinnerSelected(_east, 'finals', 0, team);
                    },
                    isFinale: true,
                  ),
                )
              else
                _buildEmptySlot(loc.pickYourChampion),
            ],
          ),
        );
      },
    );
  }

  // ─── Pick a seed (opens team picker with all 30 teams) ───
  Future<void> _pickSeed(ConferenceBracket conf, int seedIndex) async {
    if (_isValidated) return;

    // Collect teams already used in both conferences (except current slot)
    final usedTeams = <String>{};
    for (int i = 0; i < 10; i++) {
      if (i != seedIndex && conf.seeds[i] != null) {
        usedTeams.add(conf.seeds[i]!);
      }
    }
    // Also exclude teams from the other conference
    final otherConf = (conf == _east) ? _west : _east;
    for (int i = 0; i < 10; i++) {
      if (otherConf.seeds[i] != null) {
        usedTeams.add(otherConf.seeds[i]!);
      }
    }

    final available = allNbaTeams.where((t) => !usedTeams.contains(t)).toList();
    final picked = await _showTeamPicker(allowedTeams: available);
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
    final hasWinner = winner != null;

    return Container(
      width: 170,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFinale
              ? AppColors.accentPrimary.withValues(alpha: 0.5)
              : hasWinner
                  ? getTeamColor(winner).withValues(alpha: 0.3)
                  : AppColors.borderDark,
          width: isFinale ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (hasWinner ? getTeamColor(winner) : Colors.black).withValues(alpha: hasWinner ? 0.08 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Team A row
          _buildTeamRow(
            team: teamA,
            seed: seedA,
            isSelected: winner != null && winner == teamA,
            isEliminated: winner != null && winner != teamA,
            isTop: true,
            hasSubtitle: subtitle != null,
            onTapTeam: onSelectTeamA,
            onTapWinner: (teamA != null && teamB != null && onPickWinner != null)
                ? () => onPickWinner(teamA)
                : null,
          ),
          // VS divider
          Stack(
            alignment: Alignment.center,
            children: [
              Container(height: 1, color: AppColors.borderDark),
              if (teamA != null && teamB != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderDark, width: 0.5),
                  ),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
            ],
          ),
          // Team B row
          _buildTeamRow(
            team: teamB,
            seed: seedB,
            isSelected: winner != null && winner == teamB,
            isEliminated: winner != null && winner != teamB,
            isTop: false,
            hasSubtitle: subtitle != null,
            onTapTeam: onSelectTeamB,
            onTapWinner: (teamA != null && teamB != null && onPickWinner != null)
                ? () => onPickWinner(teamB)
                : null,
          ),
          if (subtitle != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceHover,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
              ),
              child: Text(
                subtitle,
                style: TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.w500),
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
    bool isEliminated = false,
    required bool isTop,
    bool hasSubtitle = false,
    VoidCallback? onTapTeam,
    VoidCallback? onTapWinner,
  }) {
    if (team == null) {
      return GestureDetector(
        onTap: onTapTeam,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: isTop ? const Radius.circular(11) : Radius.zero,
                  bottom: (!isTop && !hasSubtitle) ? const Radius.circular(11) : Radius.zero,
                ),
                color: onTapTeam != null
                    ? AppColors.accentPrimary.withValues(alpha: 0.03 * _pulseAnimation.value)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  if (seed != null) ...[
                    _buildSeedBadge(seed),
                    const SizedBox(width: 6),
                  ],
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.textTertiary.withValues(alpha: 0.3 + 0.2 * _pulseAnimation.value),
                        width: 1.5,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '?',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      onTapTeam != null ? 'Tap to pick' : '...',
                      style: TextStyle(
                        color: AppColors.textTertiary.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  if (onTapTeam != null)
                    Icon(Icons.add_circle_outline, color: AppColors.textTertiary.withValues(alpha: 0.5), size: 16),
                ],
              ),
            );
          },
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: isTop ? const Radius.circular(11) : Radius.zero,
            bottom: (!isTop && !hasSubtitle) ? const Radius.circular(11) : Radius.zero,
          ),
          color: isSelected
              ? color.withValues(alpha: 0.12)
              : isEliminated
                  ? AppColors.surfaceHover.withValues(alpha: 0.5)
                  : Colors.transparent,
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Team color accent stripe
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 4,
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: isTop ? const Radius.circular(11) : Radius.zero,
                    bottomLeft: (!isTop && !hasSubtitle) ? const Radius.circular(11) : Radius.zero,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      if (seed != null) ...[
                        _buildSeedBadge(seed, isSelected: isSelected, color: color),
                        const SizedBox(width: 4),
                      ],
                      Text(emoji, style: TextStyle(fontSize: 18, color: isEliminated ? Colors.grey : null)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          shortName,
                          style: TextStyle(
                            color: isSelected
                                ? color
                                : isEliminated
                                    ? AppColors.textTertiary
                                    : AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            decoration: isEliminated ? TextDecoration.lineThrough : null,
                            decorationColor: AppColors.textTertiary.withValues(alpha: 0.5),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check, color: color, size: 12),
                        ),
                      if (onTapTeam != null && !isSelected && !isEliminated)
                        Icon(Icons.swap_horiz, color: AppColors.textTertiary.withValues(alpha: 0.4), size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeedBadge(int seed, {bool isSelected = false, Color? color}) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected && color != null
            ? color.withValues(alpha: 0.2)
            : AppColors.surfaceHover,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$seed',
        style: TextStyle(
          color: isSelected && color != null ? color : AppColors.textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptySlot(String? label) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: 170,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderDark.withValues(alpha: 0.4 + 0.3 * _pulseAnimation.value),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.sports_basketball,
                color: AppColors.textTertiary.withValues(alpha: 0.2 + 0.15 * _pulseAnimation.value),
                size: 20,
              ),
              if (label != null) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textTertiary.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─── League Brackets Comparison Page ───────────────────────
class _LeagueBracketsPage extends StatelessWidget {
  final String leagueName;
  final List<Map<String, dynamic>> brackets;

  const _LeagueBracketsPage({
    required this.leagueName,
    required this.brackets,
  });

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${loc.leagueBrackets} - $leagueName',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: brackets.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  loc.noBracketsYet,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: brackets.length,
              itemBuilder: (context, index) {
                final bracket = brackets[index];
                final userName = bracket['user_name'] as String? ?? '?';
                final data = bracket['bracket_data'] as Map<String, dynamic>? ?? {};
                final validatedAt = bracket['validated_at'] as String?;
                final eastData = data['east'] as Map<String, dynamic>? ?? {};
                final westData = data['west'] as Map<String, dynamic>? ?? {};
                final finalsWinner = data['finals_winner'] as String?;

                return _BracketCompareCard(
                  userName: userName,
                  eastData: eastData,
                  westData: westData,
                  finalsWinner: finalsWinner,
                  validatedAt: validatedAt,
                  loc: loc,
                );
              },
            ),
    );
  }
}

class _BracketCompareCard extends StatelessWidget {
  final String userName;
  final Map<String, dynamic> eastData;
  final Map<String, dynamic> westData;
  final String? finalsWinner;
  final String? validatedAt;
  final AppLocalizations loc;

  const _BracketCompareCard({
    required this.userName,
    required this.eastData,
    required this.westData,
    required this.finalsWinner,
    required this.validatedAt,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final eastConf = ConferenceBracket()..loadFromJson(eastData);
    final westConf = ConferenceBracket()..loadFromJson(westData);

    String formattedDate = '';
    if (validatedAt != null) {
      try {
        final dt = DateTime.parse(validatedAt!).toLocal();
        formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(dt);
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppColors.cardDecoration(borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: AppColors.accentPrimary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    userName,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (finalsWinner != null) ...[
                  Text(
                    '${getTeamEmoji(finalsWinner!)} ${getShortName(finalsWinner!)}',
                    style: TextStyle(
                      color: getTeamColor(finalsWinner!),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('\u{1F3C6}', style: TextStyle(fontSize: 16)),
                ],
              ],
            ),
          ),
          // Bracket summary
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // East conference summary
                _buildConfSummary(loc.eastConference, eastConf, true),
                const SizedBox(height: 8),
                // West conference summary
                _buildConfSummary(loc.westConference, westConf, false),
                if (formattedDate.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${loc.validatedOn} $formattedDate',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfSummary(String confName, ConferenceBracket conf, bool isEast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              isEast ? '\u{1F7E6}' : '\u{1F7E5}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 4),
            Text(
              confName.toUpperCase(),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            if (conf.confFinalsWinner != null) ...[
              const SizedBox(width: 8),
              Text(
                '${getTeamEmoji(conf.confFinalsWinner!)} ${getShortName(conf.confFinalsWinner!)}',
                style: TextStyle(
                  color: getTeamColor(conf.confFinalsWinner!),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        // Show round 1 winners as chips
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final winner in conf.round1Winners)
              if (winner != null) _buildTeamChip(winner),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamChip(String team) {
    final color = getTeamColor(team);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${getTeamEmoji(team)} ${getShortName(team)}',
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ─── Custom Painters ─────────────────────────────────────

/// Draws bracket-style connector arrows between stages.
class _BracketConnectorPainter extends CustomPainter {
  final Color color;
  final Color accentColor;

  _BracketConnectorPainter({required this.color, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final midY = size.height / 2;

    // Horizontal line with arrow
    path.moveTo(0, midY);
    path.lineTo(size.width - 6, midY);

    // Arrow head
    path.moveTo(size.width - 10, midY - 4);
    path.lineTo(size.width - 4, midY);
    path.lineTo(size.width - 10, midY + 4);

    canvas.drawPath(path, paint);

    // Small accent dot at midpoint
    final dotPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, midY), 1.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Draws sparkle/shimmer effect on champion banner.
class _SparklePainter extends CustomPainter {
  final double progress;
  final Color color;

  _SparklePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42); // fixed seed for consistent sparkle positions
    final paint = Paint()..color = color;

    for (int i = 0; i < 12; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final sparkleProgress = ((progress + i * 0.08) % 1.0);
      final opacity = (sin(sparkleProgress * pi) * 0.8).clamp(0.0, 1.0);
      final radius = 1.0 + sparkleProgress * 1.5;

      paint.color = color.withValues(alpha: opacity * 0.6);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
