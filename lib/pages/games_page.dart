import 'package:flutter/material.dart';
import 'package:HoopsBets/pages/bucket_page.dart';
import 'package:HoopsBets/pages/passed_bets.dart';
import 'package:HoopsBets/pages/sign_in_page.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

    final newPoints = (userData!['points'] ?? 0) + points;

    await supabase
        .from('usersdata')
        .update({'points': newPoints})
        .eq('id', widget.uid);

    setState(() {
      userData!['points'] = newPoints;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You earned $points points!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.jpeg', height: 30),
            const SizedBox(width: 8),
            const Text("HoopsBets"),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      drawer: Drawer(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userData?['user_name'] ?? 'No name'),
              accountEmail: Text(userData?['email'] ?? 'No email'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.blue, size: 40),
              ),
              decoration: const BoxDecoration(color: Colors.blueAccent),
            ),
            ListTile(
              leading: const Icon(Icons.stars),
              title: Text('Points : ${userData?['points'] ?? 0}'),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("My bets"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MyBetsPage(uid: widget.uid)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text('Timezone : ${userData?['timezone'] ?? 'N/A'}'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: Text(AppLocalizations.of(context)!.reloadData),
              onTap: () {
                Navigator.pop(context);
                _loadUserData();
                setState(() {
                  bets.clear();
                  betsNotifier.value = [];
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                AppLocalizations.of(context)!.logout,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),

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

          final games = snapshot.data!;
          final filteredGames = games.where((game) {
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

              return Dismissible(
                key: Key(game['id'].toString()),
                background: Container(
                  color: Colors.blueAccent,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  String selectedTeam;
                  Map<String, dynamic> betToAdd;

                  if (direction == DismissDirection.startToEnd) {
                    selectedTeam = homeTeam;
                    betToAdd = {
                      'pickedTeam': homeTeam,
                      'odd': game['odd_home_team'],
                      'start_time': game['start_time'],
                      'game_id': game['id']
                    };
                  } else {
                    selectedTeam = awayTeam;
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
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset("assets/images/${homeTeam.split(' ').last}.png", height: 48),
                            Text(
                              "$homeTeam - $awayTeam",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Image.asset("assets/images/${awayTeam.split(' ').last}.png", height: 48),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${game['odd_home_team']}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${game['odd_away_team']}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.startsAt(
                            DateFormat.yMd()
                                .add_jm()
                                .format(DateTime.parse(game['start_time']).toLocal()),
                          ),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
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
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 36),
            label: Text("(${bets.length})"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
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
}
