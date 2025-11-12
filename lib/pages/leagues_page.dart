import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

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
      final data = await supabase.from('leagues').select();
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
    final name = _leagueNameController.text.trim();
    if (name.isEmpty) return;

    try {
      final existing = await supabase
          .from('leagues')
          .select('id')
          .eq('name', name)
          .maybeSingle();

      if (existing != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.leagueExists)),
        );
        return;
      }

      await supabase.from('leagues').insert({
        'name': name,
        'users_id': [widget.uid],
      });

      _leagueNameController.clear();
      _loadLeagues();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.leagueCreated)),
      );
    } catch (e) {
      debugPrint('Erreur création league: $e');
    }
  }

  Future<void> _joinLeague() async {
    final leagueName = _joinLeagueController.text.trim();
    if (leagueName.isEmpty) return;

    try {
      final league = await supabase
          .from('leagues')
          .select()
          .eq('name', leagueName)
          .single();

      final leagueId = league['id'];
      List users = List.from(league['users_id'] ?? []);
      if (!users.contains(widget.uid)) users.add(widget.uid);

      await supabase.from('leagues').update({'users_id': users}).eq('id', leagueId);

      final user = await supabase
          .from('usersdata')
          .select('leagues')
          .eq('id', widget.uid)
          .single();

      List<String> userLeagues = List<String>.from(user['leagues'] ?? []);
      if (!userLeagues.contains(leagueId)) {
        userLeagues.add(leagueId);

        await supabase
            .from('usersdata')
            .update({'leagues': userLeagues})
            .eq('id', widget.uid);
      }

      _joinLeagueController.clear();
      _loadLeagues();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.leagueJoined)),
      );
    } catch (e) {
      debugPrint('Erreur join league: $e');
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
        title: Text(
          t.leagues,
          style: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
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
                  ? const Center(child: CircularProgressIndicator(color: accentPrimary))
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Création de ligue
                  Text(
                    t.createLeague,
                    style: const TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
                    style: const TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
                    style: const TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
                            color: Colors.white.withValues(alpha: 0.08),
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
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: textSecondary),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: accentPrimary.withValues(alpha: 0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
