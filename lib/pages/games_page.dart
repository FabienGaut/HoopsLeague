import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hoopsleague/pages/bucket_page.dart';
import 'package:hoopsleague/pages/passed_bets.dart';
import 'package:hoopsleague/pages/ranking_page.dart';
import 'package:hoopsleague/pages/sign_in_page.dart';

import 'package:hoopsleague/services/clock.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import 'package:hoopsleague/theme/utils.dart';
import 'package:hoopsleague/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cache_service.dart';
import '../utils/security_utils.dart';
import '../widgets/ad_banner_widget.dart';
import 'bug_page.dart';
import 'graph_page.dart';
import 'leagues_page.dart';
import 'manage_account_page.dart';

final supabase = Supabase.instance.client;

class GamesPage extends StatefulWidget {
  final String uid;

  const GamesPage({super.key, required this.uid});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final List<Map<String, dynamic>> bets = [];
  final ValueNotifier<List<Map<String, dynamic>>> betsNotifier = ValueNotifier([]);
  Map<String, dynamic>? userData;
  bool isLoading = true;

  static const Map<String, String> teamEmojis = {
    'Celtics': '🍀',
    'Nets': '🕸',
    '76ers': '⭐',
    'Knicks': '🗽',
    'Raptors': '🦖',
    'Bulls': '🐂',
    'Cavaliers': '🛡️',
    'Pistons': '🔧',
    'Pacers': '🟡',
    'Bucks': '🦌',
    'Hawks': '🦅',
    'Heat': '🔥',
    'Hornets': '🐝',
    'Magic': '🪄',
    'Wizards': '🧙',
    'Nuggets': '⛏️',
    'Timberwolves': '🐺',
    'Thunder': '⛈️',
    'Trail Blazers': '🔥',
    'Jazz': '🎷',
    'Warriors': '⚔️',
    'Clippers': '🛳️',
    'Lakers': '🌴',
    'Suns': '☀️',
    'Kings': '👑',
    'Mavericks': '🤠',
    'Rockets': '🚀',
    'Grizzlies': '🐻',
    'Pelicans': '🦩',
    'Spurs': '🌵',
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
    for (var entry in teamColors.entries) {
      if (teamName.contains(entry.key)) return entry.value;
    }
    return AppColors.primaryBlue;
  }

  String getTeamEmoji(String teamName) {
    for (var entry in teamEmojis.entries) {
      if (teamName.contains(entry.key)) return entry.value;
    }
    return '🏀';
  }

  /// Convertit un nom court d'équipe (ex: 'LAL', 'BOS') en code de ville (ex: 'LA', 'BOS')
  /// Utile pour afficher uniquement le code de la ville sans le nom de l'équipe
  String shortNameToCity(String shortName) {
    // Map des noms courts vers les codes de ville
    const Map<String, String> cityMap = {
      // Équipes avec codes de ville différents
      'LAL': 'LA',  // Los Angeles Lakers
      'LAC': 'LA',  // Los Angeles Clippers
      'GSW': 'GS',  // Golden State Warriors
      'NYK': 'NY',  // New York Knicks
      'BKN': 'BKN',  // Brooklyn Nets
      'NOP': 'NO',  // New Orleans Pelicans

      // Équipes où le code de ville est identique au nom court
      'BOS': 'BOS', // Boston Celtics
      'MIA': 'MIA', // Miami Heat
      'PHI': 'PHI', // Philadelphia 76ers
      'TOR': 'TOR', // Toronto Raptors
      'CHI': 'CHI', // Chicago Bulls
      'CLE': 'CLE', // Cleveland Cavaliers
      'DET': 'DET', // Detroit Pistons
      'IND': 'IND', // Indiana Pacers
      'MIL': 'MIL', // Milwaukee Bucks
      'ATL': 'ATL', // Atlanta Hawks
      'CHA': 'CHA', // Charlotte Hornets
      'ORL': 'ORL', // Orlando Magic
      'WAS': 'WAS', // Washington Wizards
      'DEN': 'DEN', // Denver Nuggets
      'MIN': 'MIN', // Minnesota Timberwolves
      'OKC': 'OKC', // Oklahoma City Thunder
      'POR': 'POR', // Portland Trail Blazers
      'UTA': 'UTA', // Utah Jazz
      'PHX': 'PHX', // Phoenix Suns
      'SAC': 'SAC', // Sacramento Kings
      'DAL': 'DAL', // Dallas Mavericks
      'HOU': 'HOU', // Houston Rockets
      'MEM': 'MEM', // Memphis Grizzlies
      'SAS': 'SAS', // San Antonio Spurs
    };

    return cityMap[shortName] ?? shortName;
  }

  String formatGameTime(String utcString, Clock clock) {
    try {
      final utcTime = DateTime.parse(utcString).toUtc();
      final localTime = clock.toLocalTime(utcTime);
      return DateFormat('EEE d MMM - HH:mm').format(localTime);
    } catch (_) {
      return utcString;
    }
  }

  String convertOdds(double frOdd, String oddsFormat) {
    switch (oddsFormat.toUpperCase()) {
      case 'FR':
        return frOdd.toStringAsFixed(2);
      case 'UK':
        double fraction = frOdd - 1;
        return _toFraction(fraction);
      case 'US':
        if (frOdd >= 2.0) {
          return '+${((frOdd - 1) * 100).round()}';
        } else {
          return (-100 / (frOdd - 1)).round().toString();
        }
      default:
        return frOdd.toStringAsFixed(2);
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
            (route) => false,
      );
    }
  }

  String _toFraction(double value) {
    const tolerance = 1.0e-6;
    int numerator = 1;
    int denominator = 1;
    double error = (numerator / denominator - value).abs();

    while (error > tolerance && denominator < 100) {
      if (numerator / denominator < value) {
        numerator++;
      } else {
        denominator++;
        numerator = (value * denominator).round();
      }
      error = (numerator / denominator - value).abs();
    }

    return "$numerator/$denominator";
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _addPoints(int points) async {
    final messenger = ScaffoldMessenger.of(context);
    if (userData == null) return;
    
    // Security: Validate user ID
    try {
      SecurityUtils.requireCurrentUser(widget.uid);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.unauthorizedAccess),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final response = await supabase
        .from('usersdata')
        .select('daily_points_used')
        .eq('id', widget.uid)
        .single();

    final bool dailyPointsUsed = response['daily_points_used'] ?? false;
    if (!dailyPointsUsed) {
      final newPoints = (userData!['points'] ?? 0) + points;

      await supabase
          .from('usersdata')
          .update({'points': newPoints, 'daily_points_used': true})
          .eq('id', widget.uid);

      setState(() {
        userData!['points'] = newPoints;
        _loadUserData();
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text('You earned $points points!'),
          backgroundColor: Colors.green,
        ),
      );}
  }

  Future<void> syncUserPoints(String uid) async {
    final nav = Navigator.of(context);
    final ctx = context.read<Clock>();
    
    // Security: Validate user ID
    try {
      SecurityUtils.requireCurrentUser(uid);
    } catch (e) {
      debugPrint('Security error in syncUserPoints: $e');
      return;
    }
    
    try {
      // 1️⃣ Récupérer tous les paris du joueur
      final bets = await supabase
          .from('bets')
          .select('points_betted, odd, status, reward_given')
          .eq('user_id', uid);

      double totalWon = 0;

      // 2️⃣ Calculer les gains non encore crédités
      for (var bet in bets) {
        final isWon = bet['status'] == 'won';
        final alreadyCredited = bet['reward_given'] ?? false;

        if (isWon && !alreadyCredited) {
          final amount = (bet['points_betted'] ?? 0).toDouble();
          final odd = (bet['odd'] ?? 1.0).toDouble();
          totalWon += amount * odd;

          // Marquer le gain comme crédité en BDD
          await supabase
              .from('bets')
              .update({'reward_given': true})
              .eq('user_id', uid)
              .eq('status', 'won');
        }
      }

      // 3️⃣ Récupérer le solde actuel depuis la BDD
      final user = await supabase
          .from('usersdata')
          .select('points')
          .eq('id', uid)
          .single();

      final currentPoints = (user['points'] ?? 0).toDouble();
      final newPoints = (currentPoints + totalWon);

      // 4️⃣ Mettre à jour la BDD uniquement si nécessaire
      // 4️⃣ Mettre à jour la BDD uniquement si nécessaire
      if (totalWon > 0) {
        await supabase
            .from('usersdata')
            .update({'points': newPoints})
            .eq('id', uid);

        // ✅ ANIMATION POPUP ici
        if (mounted) {
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: '',
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder: (context, animation1, animation2) {
              return Align(
                alignment: Alignment.center,
                child: Container(
                  height: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.amber, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.pointsAdded(double.parse(totalWon.toStringAsFixed(2))),
                        textAlign: TextAlign.center,
                        style:  TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: logScale(context, 22),
                          height: 1.3,
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
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0)
                      .animate(CurvedAnimation(parent: anim1, curve: Curves.elasticOut)),
                  child: child,
                ),
              );
            },
          );

          // Fermeture automatique après 2 secondes
          Future.delayed(const Duration(seconds: 2), () {
            if (nav.canPop()) nav.pop();
          });
        }

      }


      // 5️⃣ Sauvegarder le solde + timestamp uniquement dans le cache
      await CacheService.saveUserPoints(
          widget.uid, newPoints, ctx.now());

    } catch (e) {
      debugPrint('Erreur syncUserPoints: $e');
    }
  }

  Future<void> _loadUserData() async {
    // Security: Validate user ID
    try {
      SecurityUtils.requireCurrentUser(widget.uid);
    } catch (e) {
      debugPrint('Security error in _loadUserData: $e');
      setState(() => isLoading = false);
      return;
    }
    
    try {
      final data = await supabase
          .from('usersdata')
          .select()
          .eq('id', widget.uid)
          .single();

      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown, // rétrécit si nécessaire
          child: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: kToolbarHeight * 0.6, // proportion de l’AppBar
              ),
              SizedBox(width: kToolbarHeight * 0.2),
              Text(
                "HoopsLeague",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: kToolbarHeight * 0.4, // proportion de l’AppBar
                ),
              ),
            ],
          ),
        ),

        iconTheme: const IconThemeData(color: Colors.white),

      ),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.backgroundDark,
                  AppColors.surfaceDark.withValues(alpha: 0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from('upcoming_scheduled_games')
                  .stream(primaryKey: ['id'])
                  .order('start_time', ascending: true),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/images/logo.png',
                          width: 200,
                          height: 200,
                          opacity: const AlwaysStoppedAnimation(0.3),
                        ),
                        const SizedBox(height: 32),
                        // Message
                        Text(
                          AppLocalizations.of(context)!.noGamesToday,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: logScale(context, 20),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final clock = Provider.of<Clock>(context, listen: false);
                final nowLocal = clock.now();
                final games = snapshot.data!;

                final filteredGames = games.where((game) {
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

                // Calculate total items: games + ads (1 ad every 5 games)
                final int totalGames = filteredGames.length;
                final int numberOfAds = totalGames ~/ 5;
                final int totalItems = totalGames + numberOfAds;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: totalItems,
                  itemBuilder: (context, index) {
                    // Determine if this position should show an ad
                    // Ad positions: 5, 11, 17, 23... (after every 5 games)
                    final int adFrequency = 6; // 5 games + 1 ad
                    final bool isAdPosition = (index + 1) % adFrequency == 0 && index > 0;

                    if (isAdPosition) {
                      // Display ad
                      return const AdBannerWidget();
                    }

                    // Calculate the actual game index (accounting for ads before this position)
                    final int adsBeforeThisIndex = index ~/ adFrequency;
                    final int gameIndex = index - adsBeforeThisIndex;

                    // Safety check
                    if (gameIndex >= filteredGames.length) {
                      return const SizedBox.shrink();
                    }

                    final game = filteredGames[gameIndex];
                    final homeTeam = game['home_team'];
                    final awayTeam = game['away_team'];
                    final homeTeamShort = game['home_team_short'] ?? '';
                    final awayTeamShort = game['away_team_short'] ?? '';
                    final oddAway = convertOdds(
                      (game['odd_away_team'] as num).toDouble(),
                      (userData?['oddsformat'] ?? 'FR') as String,
                    );
                    final oddHome = convertOdds(
                      (game['odd_home_team'] as num).toDouble(),
                      (userData?['oddsformat'] ?? 'FR') as String,
                    );

                    return Dismissible(
                      key: Key(game['id'].toString()),
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              getTeamColor(homeTeam),
                              getTeamColor(homeTeam).withValues(alpha: 0.7),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 48),
                            SizedBox(height: 8),
                            Text(
                              shortNameToCity(homeTeamShort),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: logScale(context, 20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      secondaryBackground: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              getTeamColor(awayTeam).withValues(alpha: 0.7),
                              getTeamColor(awayTeam),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 48),
                            SizedBox(height: 8),
                            Text(
                              shortNameToCity(awayTeamShort),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: logScale(context, 20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
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
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.surfaceDark,
                              AppColors.surfaceDark.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.primaryBlue.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Column(
                            children: [
                              // En-tête moderne avec date
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.4),
                                      Colors.black.withValues(alpha: 0.2),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: AppColors.primaryBlue,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        formatGameTime(game['start_time'], clock),
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: logScale(context, 14),
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                              // Corps de la carte
                              Padding(
                                padding: const EdgeInsets.all(24),
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
                                        getTeamEmoji(homeTeam),
                                      ),
                                    ),
                                    // VS au centre
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.primaryBlue.withValues(alpha: 0.3),
                                                  AppColors.primaryBlue.withValues(alpha: 0.1),
                                                ],
                                              ),
                                              border: Border.all(
                                                color: AppColors.primaryBlue.withValues(alpha: 0.5),
                                                width: 2,
                                              ),
                                            ),
                                            child: Text(
                                              "VS",
                                              style: TextStyle(
                                                color: AppColors.primaryBlue,
                                                fontSize: logScale(context, 14),
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ),
                                        ],
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
                                        getTeamEmoji(awayTeam),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Footer avec instruction
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.2),
                                      Colors.black.withValues(alpha: 0.4),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.swipe,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)!.slideToBet,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: logScale(context, 12),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: betsNotifier,
        builder: (context, bets, _) {
          if (bets.isEmpty) return const SizedBox.shrink();

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue,
                  AppColors.primaryBlue.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BucketPage(
                      bets: List<Map<String, dynamic>>.from(bets),
                      uid: widget.uid,
                    ),
                  ),
                );

                if (result != null && result is List<Map<String, dynamic>>) {
                  setState(() {
                    betsNotifier.value = result;
                  });
                } else {
                  _loadUserData();
                  this.bets.clear();
                  betsNotifier.value = [];
                }
              },
              icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 28),
              label: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${bets.length}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: logScale(context, 16),
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );

  }
  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surfaceDark,
      child: isLoading
          ?  Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.backgroundDark, AppColors.surfaceDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.borderDark, width: 1),
              ),
            ),
            child: FittedBox( // <-- Ajout
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryBlue, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.surfaceDark,
                      child: Text(
                        (userData?['user_name'] ?? 'U')[0].toUpperCase(),
                        style:  TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: logScale(context, 24),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  AutoSizeText( // <-- pour auto-ajuster le nom
                    userData?['user_name'] ?? 'No name',
                    maxLines: 1,
                    style:  TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: logScale(context, 20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),

                  AutoSizeText(
                    'Points : ${userData?['points'] ?? 0}',
                    maxLines: 1,
                    style:  TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: logScale(context, 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildDrawerItem(
            icon: Icons.history_rounded,
            title: AppLocalizations.of(context)!.myBets,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyBetsPage(uid: widget.uid),
                ),
              );
            },
          ), const SizedBox(height: 8),

          if (userData?['daily_points_used'] == false)
            _buildDrawerItem(
              icon: Icons.control_point_rounded,
              title: AppLocalizations.of(context)!.dailyPoints,
              onTap: () {
                _addPoints(10);
                _loadUserData();
              },
            )
          else
            _buildDrawerItem(
              icon: Icons.not_interested,
              title: AppLocalizations.of(context)!.dailyPointsTaken,
              textColor: Colors.grey,
              iconColor: Colors.grey,
              onTap: null,
            ),
          const SizedBox(height: 8),
          _buildDrawerItem(
            icon: Icons.people,
            title: AppLocalizations.of(context)!.leagues,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeaguesPage(uid: widget.uid),
                ),
              );
            },
          ),const SizedBox(height: 8),
          _buildDrawerItem(
            icon: Icons.account_box,
            title: AppLocalizations.of(context)!.manageAccount,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManageAccountPage(uid: widget.uid),
                ),
              );
            },
          ),const SizedBox(height: 8),
          _buildDrawerItem(
            icon: Icons.refresh,
            title: AppLocalizations.of(context)!.reloadData,
            onTap: () {
              Navigator.pop(context); // ferme le drawer
              _loadUserData();
              syncUserPoints(widget.uid);
              setState(() {
                bets.clear();
                betsNotifier.value = [];
              });
            },
          ),
          _buildDrawerItem(
            icon: Icons.leaderboard,
            title: AppLocalizations.of(context)!.rankings,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeaderboardPage(uid: widget.uid),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildDrawerItem(
            icon: Icons.line_axis_outlined,
            title: AppLocalizations.of(context)!.myGraph,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PointsGraphPage(uid: widget.uid,),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildDrawerItem(
            icon: Icons.bug_report,
            title: AppLocalizations.of(context)!.bugReport,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BugPage(uid: widget.uid),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Divider(color: AppColors.borderDark, height: 32, indent: 16, endIndent: 16),
          _buildDrawerItem(
            icon: Icons.logout_rounded,
            title: AppLocalizations.of(context)!.logout,
            textColor: Colors.red[400],
            iconColor: Colors.red[400],
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primaryBlue),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: logScale(context, 15),
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildTeamCard(
    BuildContext context,
    String teamName,
    String teamShort,
    String odd,
    Color teamColor,
    String emoji,
  ) {
    return Column(
      children: [
        // Emoji avec fond coloré
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                teamColor.withValues(alpha: 0.3),
                teamColor.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: teamColor.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: teamColor.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child:

          Text(
            emoji,
            style: TextStyle(fontSize: logScale(context, 28),
              fontFamily: GoogleFonts.notoColorEmoji().fontFamily,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Abréviation de l'équipe
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: teamColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            shortNameToCity(teamShort),
            style: TextStyle(
              color: teamColor,
              fontWeight: FontWeight.bold,
              fontSize: logScale(context, 16),
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Nom complet de l'équipe
        AutoSizeText(
          teamName,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: logScale(context, 13),
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          minFontSize: 10,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        // Cote
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                teamColor.withValues(alpha: 0.25),
                teamColor.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: teamColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Text(
            odd,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: logScale(context, 18),
            ),
          ),
        ),
      ],
    );
  }
}
