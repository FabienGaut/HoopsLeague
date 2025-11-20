import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/utils.dart';

final supabase = Supabase.instance.client;

class LeaguesPage extends StatefulWidget {
  final String uid;

  const LeaguesPage({super.key, required this.uid});

  @override
  State<LeaguesPage> createState() => _LeaguesPageState();
}

class _LeaguesPageState extends State<LeaguesPage> {
  static const Color accentPrimary = Color(0xFF256af4);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;

  final TextEditingController _leagueNameController = TextEditingController();
  final TextEditingController _joinLeagueController = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> leagues = [];

  @override
  void initState() {
    super.initState();
    _loadLeagues();
  }

  Future<void> _loadLeagues() async {
    setState(() => isLoading = true);
    try {
      final data = await supabase.from('leagues')
          .select()
          .contains('users_id', [widget.uid]);
      setState(() {
        leagues = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint('Erreur chargement leagues: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _createLeague() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final name = _leagueNameController.text.trim();
    if (name.isEmpty) return;

    try {
      final existing = await supabase
          .from('leagues')
          .select('id')
          .eq('name', name)
          .maybeSingle();

      if (existing != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(t.leagueExists)),
        );
        return;
      }

      await supabase.from('leagues').insert({
        'name': name,
        'users_id': [widget.uid],
      });

      _leagueNameController.clear();
      _loadLeagues();
      messenger.showSnackBar(
        SnackBar(content: Text(t.leagueCreated)),
      );
    } catch (e) {
      debugPrint('Erreur création league: $e');
    }
  }

  Future<void> _joinLeague() async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);

    final leagueName = _joinLeagueController.text.trim();
    if (leagueName.isEmpty) return;

    try {
      // Récupérer la ligue par son nom
      final league = await supabase
          .from('leagues')
          .select('id')
          .eq('name', leagueName)
          .single();

      final leagueId = league['id'];

      // Appel de la fonction RPC join_league
      await supabase.rpc('join_league', params: {'league_id': leagueId});

      _joinLeagueController.clear();
      _loadLeagues();
      messenger.showSnackBar(
        SnackBar(content: Text(t.leagueJoined)),
      );
    } catch (e) {
      debugPrint('Erreur join league: $e');
      messenger.showSnackBar(
        SnackBar(content: Text(t.enterLeagueName)),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                t.myLeagues,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: kToolbarHeight * 0.4, // proportion de l’AppBar
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // 🌌 Dégradé violet → noir
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF314368), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.3)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isLoading
                  ? const Center(
                  child: CircularProgressIndicator(color: accentPrimary))
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Création de ligue
                  Text(
                    t.createLeague,
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: logScale(context, 18),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _glassInputRow(
                    controller: _leagueNameController,
                    hint: t.leagueName,
                    buttonText: t.create,
                    onPressed: _createLeague,
                  ),
                  const SizedBox(height: 24),

                  // 🔹 Rejoindre une ligue
                  Text(
                    t.joinLeague,
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: logScale(context, 18),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _glassInputRow(
                    controller: _joinLeagueController,
                    hint: t.enterLeagueName,
                    buttonText: t.join,
                    onPressed: _joinLeague,
                  ),
                  const SizedBox(height: 24),

                  // 🔹 Liste des ligues
                  Text(
                    t.myLeagues,
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: logScale(context, 18),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: leagues.isEmpty
                        ? Center(
                      child: Text(
                        t.noMembersInLeague,
                        style: const TextStyle(color: textSecondary),
                      ),
                    )
                        : ListView.builder(
                      itemCount: leagues.length,
                      itemBuilder: (context, index) {
                        final league = leagues[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              league['name'],
                              style: const TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              t.membersCount(
                                (league['users_id'] as List?)?.length ?? 0,
                              ),
                              style: const TextStyle(color: textSecondary),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassInputRow({
    required TextEditingController controller,
    required String hint,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 48,
            decoration: BoxDecoration(
              color: Color(0xFF222F49), // même fond que GamesPage
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF222F49), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: TextField(
                maxLength: 30,
                controller: controller,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: logScale(context, 14),
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: logScale(context, 14),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue, // couleur GamesPage
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
            ),
            child: Text(
              buttonText,
              style: TextStyle(
                color: Colors.white,
                fontSize: logScale(context, 14),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
