import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

final supabase = Supabase.instance.client;

class LeaderboardPage extends StatefulWidget {
  final String uid;

  const LeaderboardPage({super.key, required this.uid});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> leagues = [];
  Map<String, dynamic>? selectedLeague;
  bool isLoading = true;

  // 🎨 Nouvelle palette cohérente
  static const Color accentPrimary = Color(0xFF256af4);
  static const Color accentGlow = Color(0xFF9C9CFF); // bleu-violet clair
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;

  @override
  void initState() {
    super.initState();
    fetchUserLeagues();
  }

  Future<void> fetchUserLeagues() async {
    setState(() => isLoading = true);
    try {
      final userData = await supabase
          .from('usersdata')
          .select('leagues')
          .eq('id', widget.uid)
          .single();

      final List<String> leagueIds = List<String>.from(userData['leagues'] ?? []);

      if (leagueIds.isEmpty) {
        setState(() {
          leagues = [];
          selectedLeague = null;
          users = [];
        });
        return;
      }

      final leaguesData =
      await supabase.from('leagues').select().filter('id', 'in', leagueIds);

      setState(() {
        leagues = List<Map<String, dynamic>>.from(leaguesData);
        if (leagues.isNotEmpty) selectedLeague = leagues.first;
      });

      if (selectedLeague != null) fetchLeaderboard();
    } catch (e) {
      debugPrint('Erreur fetch user leagues: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchLeaderboard() async {
    if (selectedLeague == null) return;

    setState(() => isLoading = true);
    try {
      final List<String> leagueUsersIds =
      List<String>.from(selectedLeague!['users_id'] ?? []);
      if (leagueUsersIds.isEmpty) {
        setState(() => users = []);
        return;
      }

      final response = await supabase
          .from('usersdata')
          .select()
          .filter('id', 'in', leagueUsersIds)
          .order('points', ascending: false);

      setState(() => users = List<Map<String, dynamic>>.from(response));
    } catch (e) {
      debugPrint('Erreur fetch leaderboard: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color getRankColor(int rank) {
    switch (rank) {
      case 1:
        return accentGlow.withOpacity(0.25);
      case 2:
        return Colors.purpleAccent.withOpacity(0.15);
      case 3:
        return Colors.indigoAccent.withOpacity(0.15);
      default:
        return Colors.white.withOpacity(0.05);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 28),
            const SizedBox(width: 8),
            Text(
              t.hoopsLeagueTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
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
          Container(color: Colors.black.withOpacity(0.3)),

          SafeArea(
            child: isLoading
                ? const Center(
                child: CircularProgressIndicator(color: accentPrimary))
                : Column(
              children: [
                if (leagues.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.25)),
                      ),
                      child: DropdownButton<Map<String, dynamic>>(
                        value: selectedLeague,
                        dropdownColor: Colors.black.withOpacity(0.8),
                        isExpanded: true,
                        underline: const SizedBox(),
                        iconEnabledColor: accentGlow,
                        items: leagues.map((league) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: league,
                            child: Text(
                              league['name'] ?? 'League',
                              style:
                              const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedLeague = value);
                          fetchLeaderboard();
                        },
                      ),
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    color: accentPrimary,
                    onRefresh: fetchLeaderboard,
                    child: users.isEmpty
                        ? ListView(
                      children: [
                        const SizedBox(height: 100),
                        Center(
                          child: Text(
                            t.noMembersInLeague,
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final rank = index + 1;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6),
                          decoration: BoxDecoration(
                            color: getRankColor(rank),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: accentGlow,
                              child: Text(
                                '$rank',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              user['user_name'] ?? t.unknownUser,
                              style: const TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: accentGlow.withOpacity(0.15),
                                borderRadius:
                                BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                  accentGlow.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${user['points'] ?? 0} ${t.pointsSuffix}',
                                style: const TextStyle(
                                  color: accentGlow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
