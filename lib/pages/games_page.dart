import 'package:HoopsBets/pages/password_change_page.dart';
import 'package:HoopsBets/pages/ranking_page.dart';
import 'package:HoopsBets/pages/test_page.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:HoopsBets/pages/bucket_page.dart';
import 'package:HoopsBets/pages/passed_bets.dart';
import 'package:HoopsBets/pages/sign_in_page.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:HoopsBets/services/cache_service.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import 'graph_page.dart';
import 'package:HoopsBets/pages/manage_account_page.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

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

  // Couleurs améliorées
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color cardBorder = Color(0xFF2A2A2A);
  static const Color accentPrimary = Colors.deepPurple;
  static const Color accentGold = Color(0xFFFFD700);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color successGreen = Color(0xFF4CAF50);

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
    'Clippers': '✂️',
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
    'Celtics': Color(0xFF007A33),
    'Nets': Color(0xFF000000),
    '76ers': Color(0xFF002AB3),
    'Knicks': Color(0xFF006BB6),
    'Raptors': Color(0xFF73007E),
    'Bulls': Color(0xFFD30C23),
    'Cavaliers': Color(0xFF860038),
    'Pistons': Color(0xFFC8102E),
    'Pacers': Color(0xFF002D62),
    'Bucks': Color(0xFF00471B),
    'Hawks': Color(0xFFE03A3E),
    'Heat': Color(0xFF98002E),
    'Hornets': Color(0xFF1D1160),
    'Magic': Color(0xFF0077C0),
    'Wizards': Color(0xFF002B5C),
    'Nuggets': Color(0xFF0E2240),
    'Timberwolves': Color(0xFF0C2340),
    'Thunder': Color(0xFF007AC1),
    'Trail Blazers': Color(0xFFFF0005),
    'Jazz': Color(0xFF002B5C),
    'Warriors': Color(0xFF1D428A),
    'Clippers': Color(0xFFC8102E),
    'Lakers': Color(0xFF552583),
    'Suns': Color(0xFF1D1160),
    'Kings': Color(0xFF5A2D81),
    'Mavericks': Color(0xFF00538C),
    'Rockets': Color(0xFFCF001C),
    'Grizzlies': Color(0xFF5D76A9),
    'Pelicans': Color(0xFF0C2340),
    'Spurs': Color(0xFF000000),
  };

  Color getTeamColor(String teamName) {
    for (var entry in teamColors.entries) {
      if (teamName.contains(entry.key)) return entry.value;
    }
    return accentPrimary;
  }

  String getTeamEmoji(String teamName) {
    for (var entry in teamEmojis.entries) {
      if (teamName.contains(entry.key)) return entry.value;
    }
    return '🏀'; // fallback
  }

  String formatGameTime(String utcString) {
    try {
      final utcTime = DateTime.parse(utcString).toUtc();
      final localTime = utcTime.toLocal();
      return DateFormat('EEE d MMM - HH:mm').format(localTime);
    } catch (_) {
      return utcString;
    }
  }

  Future<void> syncUserPoints(String uid) async {
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
      final newPoints = (currentPoints + totalWon).toInt();

      // 4️⃣ Mettre à jour la BDD uniquement si nécessaire
      if (totalWon > 0) {
        await supabase
            .from('usersdata')
            .update({'points': newPoints})
            .eq('id', uid);
      }

      // 5️⃣ Sauvegarder le solde + timestamp uniquement dans le cache
      await CacheService.saveUserPoints(newPoints);

    } catch (e) {
      debugPrint('Erreur syncUserPoints: $e');
    }
  }


  Future<void> _loadCachedPoints() async {
    final cachedPoints = await CacheService.loadUserPoints();
    setState(() {
      userData = {'points': cachedPoints};
      isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    _loadCachedPoints();
    syncUserPoints(widget.uid).then((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur chargement utilisateur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  String convertOdds(double frOdd, String oddsFormat) {

    switch (oddsFormat.toUpperCase()) {
      case 'FR':
      // Format décimal, on renvoie tel quel
        return frOdd.toStringAsFixed(2);

      case 'UK':
      // UK = (FR - 1) exprimé en fraction
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

// --- Fonction interne pour transformer un nombre en fraction (format UK) ---
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

  Future<void> _addPoints(int points) async {
    if (userData == null) return;
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
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You earned $points points!'),
        backgroundColor: Colors.green,
      ),
    );}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo_black.png', height: 30),
            const SizedBox(width: 8),
            const Text("HoopsLeague", style: TextStyle(color: Colors.white),),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      drawer: _buildDrawer(context),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase
            .from('gamesdata')
            .stream(primaryKey: ['id'])
            .eq('status', 'scheduled')
            .order('start_time', ascending: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noData));
          }
          final nowLocal = tz.TZDateTime.now(localLocation);
          final games = snapshot.data!;

          final filteredGames = games.where((game) {
            try {
              final startUtc = DateTime.parse(game['start_time']).toUtc();
              final startLocal = tz.TZDateTime.from(startUtc, localLocation);
              if (startLocal.isBefore(nowLocal)) return false;
            } catch (_) {
              return false;
            }
            final gameId = game['id'];
            // On vérifie que ce gameId n’apparaît dans aucun bet
            return !betsNotifier.value.any((b) {
              final betGameIds = b['game_id'];
              if (betGameIds is List) {
                return betGameIds.contains(gameId);
              } else {
                return betGameIds == gameId;
              }
            });
          }).toList();


          return ListView.builder(
            itemCount: filteredGames.length,
            itemBuilder: (context, index) {
              final game = filteredGames[index];
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
                  color: getTeamColor(homeTeam),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: getTeamColor(awayTeam),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.check, color: Colors.white),
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
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header with start time
                      if (game['start_time'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: cardBorder,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.schedule, size: 14, color: textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                game['start_time'].toString(),
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Teams row
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _teamWidget(
                                homeTeamShort,
                                homeTeam,
                                getTeamColor(homeTeam),
                                oddHome,
                                1.0,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                children: [
                                  Text(
                                    "VS",
                                    style: TextStyle(
                                      color: Color(0xB6FFFFFF),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(2, 2),
                                          blurRadius: 4,
                                          color: Colors.black.withOpacity(0.6),
                                        ),
                                        Shadow(
                                          offset: Offset(-2, -2),
                                          blurRadius: 4,
                                          color: Colors.black.withOpacity(0.4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(Icons.swap_horiz, color: textSecondary, size: 20),
                                ],
                              ),
                            ),
                            Expanded(
                              child: _teamWidget(
                                awayTeamShort,
                                awayTeam,
                                getTeamColor(awayTeam),
                                oddAway,
                                1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Swipe hint
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: cardBorder.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.swipe, size: 14, color: textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              'Glissez pour parier',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );

            },
          );
        },
      ),

      floatingActionButton: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: betsNotifier,
        builder: (context, bets, _) {
          return ElevatedButton.icon(
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

              // Le résultat renvoyé par BucketPage au retour
              if (result != null && result is List<Map<String, dynamic>>) {
                setState(() {
                  betsNotifier.value = result;
                });


              }
              else {
                _loadUserData();
                bets.clear();
              }
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 36),
            label: Text("(${bets.length})", style: TextStyle(color: Colors.white),),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
            ),
          );
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _teamWidget(
      String teamShort,
      String teamFull,
      Color color,
      String odd,
      double scale,
      ) {
    final emoji = getTeamEmoji(teamFull);

    return Column(

      children: [
        ClipPath(
          clipper: BasketballJerseyClipper(),
          child: Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.6), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: color.withOpacity(0.8), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: AutoSizeText(
                '$emoji\n$teamShort',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          teamFull,
          style: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: accentGold.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accentGold.withOpacity(0.5), width: 1),
          ),
          child: Text(
            odd,
            style: const TextStyle(
              color: accentGold,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: cardBg,
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: accentPrimary))
          : ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [darkBg, cardBg],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                bottom: BorderSide(color: cardBorder, width: 1),
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
                      border: Border.all(color: accentPrimary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: cardBg,
                      child: Text(
                        (userData?['user_name'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: accentPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AutoSizeText( // <-- pour auto-ajuster le nom
                    userData?['user_name'] ?? 'No name',
                    maxLines: 1,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AutoSizeText(
                    userData?['email'] ?? 'No email',
                    maxLines: 1,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  AutoSizeText(
                    'Points : ${userData?['points'] ?? 0}',
                    maxLines: 1,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildDrawerItem(
            icon: Icons.history_rounded,
            title: "Mes paris",
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
          _buildDrawerItem(
            icon: Icons.history_rounded,
            title: "Test",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TestPage(uid: widget.uid),
                ),
              );
            },
          ), const SizedBox(height: 8),

          if (userData?['daily_points_used'] == false)
            _buildDrawerItem(
              icon: Icons.control_point_rounded,
              title: "Daily points",
              onTap: () {
                _addPoints(10);
                _loadUserData();
              },
            )
          else
            _buildDrawerItem(
              icon: Icons.not_interested,
              title: "Daily points (déjà pris)",
              textColor: Colors.grey,
              iconColor: Colors.grey,
              onTap: null,
            ),
          const SizedBox(height: 8),
          _buildDrawerItem(
            icon: Icons.account_box,
            title: "Manage account",
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
              setState(() {
                bets.clear();
                betsNotifier.value = [];
              });
            },
          ),
          _buildDrawerItem(
            icon: Icons.leaderboard,
            title: "Rankings",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeaderboardPage(),
                ),
              );
            },
          ), const SizedBox(height: 8),
          _buildDrawerItem(
            icon: Icons.account_box,
            title: "My bets",
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
          _buildDrawerItem(
            icon: Icons.line_axis_outlined,
            title: "My graph",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PointsGraphPage(),
                ),
              );
            },
          ),

          const Divider(color: cardBorder, height: 32, indent: 16, endIndent: 16),
          _buildDrawerItem(
            icon: Icons.logout_rounded,
            title: "Déconnexion",
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
      leading: Icon(icon, color: iconColor ?? accentPrimary),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}


