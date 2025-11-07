import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color cardBorder = Color(0xFF2A2A2A);
  static const Color accentPrimary = Colors.deepPurple;
  static const Color accentGold = Color(0xFFFFD700);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    fetchUserLeagues();
  }

  Future<void> fetchUserLeagues() async {
    setState(() => isLoading = true);
    try {
      // Récupère les leagues de l'utilisateur
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

      // Récupère les infos des leagues
      final leaguesData = await supabase
          .from('leagues')
          .select()
          .filter('id', 'in', leagueIds); // au lieu de .in_('id', leagueIds)


      setState(() {
        leagues = List<Map<String, dynamic>>.from(leaguesData);
        if (leagues.isNotEmpty) selectedLeague = leagues[0];
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
      final List<String> leagueUsersIds = List<String>.from(selectedLeague!['users_id'] ?? []);
      if (leagueUsersIds.isEmpty) {
        setState(() => users = []);
        return;
      }

      final response = await supabase
          .from('usersdata')
          .select()
          .filter('id', 'in', leagueUsersIds) // au lieu de .in_('id', leagueUsersIds)
          .order('points', ascending: false);


      setState(() {
        users = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint('Erreur fetch leaderboard: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color getRankColor(int rank) {
    switch (rank) {
      case 1:
        return accentGold.withOpacity(0.2);
      case 2:
        return Colors.grey.withOpacity(0.2);
      case 3:
        return Colors.brown.withOpacity(0.2);
      default:
        return cardBg;
    }
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
            const Text(
              "HoopsLeague",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: accentPrimary))
          : Column(
        children: [
          if (leagues.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButton<Map<String, dynamic>>(
                value: selectedLeague,
                dropdownColor: cardBg,
                isExpanded: true,
                underline: Container(height: 1, color: cardBorder),
                iconEnabledColor: accentPrimary,
                items: leagues.map((league) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: league,
                    child: Text(
                      league['name'] ?? 'League',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedLeague = value);
                  fetchLeaderboard();
                },
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              color: accentPrimary,
              onRefresh: fetchLeaderboard,
              child: users.isEmpty
                  ? ListView(
                children: const [
                  SizedBox(height: 50),
                  Center(
                      child: Text(
                        'Aucun membre dans cette league',
                        style: TextStyle(color: Colors.white54),
                      )),
                ],
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final rank = index + 1;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: getRankColor(rank),
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
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: accentPrimary,
                        child: Text(
                          '$rank',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        user['user_name'] ?? 'Inconnu',
                        style: const TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        user['email'] ?? '',
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: accentGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: accentGold.withOpacity(0.4), width: 1),
                        ),
                        child: Text(
                          '${user['points'] ?? 0} pts',
                          style: const TextStyle(
                            color: accentGold,
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
    );
  }
}
