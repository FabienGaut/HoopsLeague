import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'bucket_page.dart';
import 'passed_bets.dart';
import 'sign_in_page.dart';
import '../l10n/app_localizations.dart';

final supabase = Supabase.instance.client;


class BasketballJerseyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Largeur des bretelles
    double strapWidth = size.width * 0.20;
    double neckDepth = size.height * 0.4;  // profondeur du col rond

    // Épaule gauche (bretelle large)
    path.lineTo(0, size.height * 0.15);
    path.moveTo(0, 0);
    path.lineTo(strapWidth, 0);

    // Faire un col rond vers la bretelle droite
    path.arcToPoint(
      Offset(size.width - strapWidth, 0),
      radius: Radius.circular(size.width * 0.31), // rayon pour arrondi
      clockwise: false,
    );


    // Épaule droite (bretelle large)
    path.lineTo(size.width - strapWidth, 0);
    path.lineTo(size.width,  0);




    // Côtés du débardeur
    path.lineTo(size.width*0.97, size.height * 0.85);
    path.lineTo(size.width*0.03, size.height * 0.85);

    // Fermeture du path
    path.lineTo(0, size.height * 0.15);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


class TestPage extends StatefulWidget {
  final String uid;
  const TestPage({super.key, required this.uid});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> bets = [];
  final ValueNotifier<List<Map<String, dynamic>>> betsNotifier = ValueNotifier([]);
  Map<String, dynamic>? userData;
  bool isLoading = true;
  late AnimationController _fabAnimationController;

  // Couleurs améliorées
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color cardBorder = Color(0xFF2A2A2A);
  static const Color accentPrimary = Color(0xFF00D9FF);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color successGreen = Color(0xFF4CAF50);

  static const Map<String, String> teamEmojis = {
    'Celtics': '🍀',
    'Nets': '🕸️',
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

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadUserData();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    betsNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await supabase.from('usersdata').select().eq('id', widget.uid).single();
      if (mounted) {
        setState(() {
          userData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showSnackBar('Erreur de chargement: ${e.toString()}', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[700] : successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion', style: TextStyle(color: textPrimary)),
        content: const Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.auth.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
              (route) => false,
        );
      }
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = dateTime.difference(now);

      if (difference.inDays == 0) {
        return 'Aujourd\'hui ${DateFormat.Hm().format(dateTime)}';
      } else if (difference.inDays == 1) {
        return 'Demain ${DateFormat.Hm().format(dateTime)}';
      } else {
        return DateFormat('dd/MM à HH:mm').format(dateTime);
      }
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textScale = (size.width / 400).clamp(0.8, 1.2);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo_black.png', height: 28),
            const SizedBox(width: 8),
            const Text(
              "HoopsBets",
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: betsNotifier,
            builder: (context, bets, _) {
              if (bets.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentPrimary, width: 1),
                    ),
                    child: Text(
                      '${bets.length} sélection${bets.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: accentPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: accentPrimary,
        backgroundColor: cardBg,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: supabase
              .from('gamesdata')
              .stream(primaryKey: ['id'])
              .eq('status', 'scheduled')
              .order('start_time'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: accentPrimary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: TextStyle(color: textPrimary, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      style: TextStyle(color: textSecondary, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final games = snapshot.data ?? [];

            if (games.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_basketball, size: 64, color: textSecondary),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun match disponible',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Revenez plus tard pour parier',
                      style: TextStyle(color: textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                final homeTeamShort = game['home_team_short'] ?? '';
                final awayTeamShort = game['away_team_short'] ?? '';
                final homeTeam = game['home_team'] ?? '';
                final awayTeam = game['away_team'] ?? '';
                final homeColor = getTeamColor(homeTeam);
                final awayColor = getTeamColor(awayTeam);

                return Dismissible(
                  key: Key(game['id'].toString()),
                  background: _buildDismissibleBackground(
                    homeTeam,
                    homeColor,
                    true,
                    game['odd_home_team']?.toString() ?? '-',
                  ),
                  secondaryBackground: _buildDismissibleBackground(
                    awayTeam,
                    awayColor,
                    false,
                    game['odd_away_team']?.toString() ?? '-',
                  ),
                  confirmDismiss: (direction) async {
                    final pickedTeam = direction == DismissDirection.startToEnd
                        ? homeTeam
                        : awayTeam;
                    final odd = direction == DismissDirection.startToEnd
                        ? game['odd_home_team']
                        : game['odd_away_team'];

                    final betToAdd = {
                      'pickedTeam': pickedTeam,
                      'odd': odd,
                      'start_time': game['start_time'],
                      'game_id': game['id'],
                    };

                    setState(() {
                      bets.add(betToAdd);
                      betsNotifier.value = [...betsNotifier.value, betToAdd];
                    });

                    _showSnackBar('$pickedTeam ajouté au panier');
                    _fabAnimationController.forward().then((_) {
                      _fabAnimationController.reverse();
                    });

                    return false; // Ne pas supprimer la carte
                  },
                  child: _buildGameCard(
                    game,
                    homeTeam,
                    awayTeam,
                    homeColor,
                    awayColor,
                    textScale,
                    homeTeamShort,
                    awayTeamShort,
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: betsNotifier,
        builder: (context, bets, _) {
          if (bets.isEmpty) return const SizedBox.shrink();

          return ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.2).animate(
              CurvedAnimation(
                parent: _fabAnimationController,
                curve: Curves.easeInOut,
              ),
            ),
            child: FloatingActionButton.extended(
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
                  setState(() => betsNotifier.value = result);
                }
              },
              backgroundColor: Colors.black12,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.shopping_cart_rounded),
              label: Text(
                'Panier (${bets.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDismissibleBackground(
      String team,
      Color color,
      bool isLeft,
      String odd,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_rounded,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            team,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '@$odd',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(
      Map<String, dynamic> game,
      String homeTeam,
      String awayTeam,
      Color homeColor,
      Color awayColor,
      double scale,
      String shortHomeTeam,
      String shortAwayTeam,
      ) {
    final startTime = game['start_time'] != null
        ? _formatDateTime(game['start_time'])
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // En-tête avec l'heure
          if (startTime.isNotEmpty)
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
                    startTime,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Corps de la carte
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _teamWidget(
                    shortHomeTeam,
                    homeTeam,
                    homeColor,
                    game['odd_home_team']?.toString() ?? '-',
                    scale,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Text(
                        "VS",
                        style: TextStyle(
                          color: Color(0xB6FFFFFF),  // couleur dorée
                          fontSize: 24,      // taille plus grande
                          fontWeight: FontWeight.w900, // ultra-bold
                          letterSpacing: 2,  // espacement des lettres
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
                      Icon(
                        Icons.swap_horiz,
                        color: textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _teamWidget(
                    shortAwayTeam,
                    awayTeam,
                    awayColor,
                    game['odd_away_team']?.toString() ?? '-',
                    scale,
                  ),
                ),
              ],
            ),
          ),

          // Indication de swipe
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
                Text(
                  userData?['user_name'] ?? 'No name',
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  userData?['email'] ?? 'No email',
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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