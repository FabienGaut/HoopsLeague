import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/cache_service.dart';

final supabase = Supabase.instance.client;

class LeaguesPage extends StatefulWidget {
  final String uid;

  const LeaguesPage({super.key, required this.uid});

  @override
  State<LeaguesPage> createState() => _LeaguesPageState();
}

class _LeaguesPageState extends State<LeaguesPage> {
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color cardBorder = Color(0xFF2A2A2A);
  static const Color accentPrimary = Colors.deepPurple;
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);

  final TextEditingController _leagueNameController = TextEditingController();
  final TextEditingController _joinLeagueController = TextEditingController();
  bool isLoading = false;
  List<Map<String, dynamic>> myLeagues = [];

  @override
  void initState() {
    super.initState();
    _loadLeagues();
  }

  Future<void> _loadLeagues() async {
    setState(() => isLoading = true);
    try {
      final data = await supabase
          .from('leagues')
          .select()
          .contains('users_id', [widget.uid]);
      setState(() {
        myLeagues = List<Map<String, dynamic>>.from(data);
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
      // Vérifier si la league existe déjà
      final existing = await supabase
          .from('leagues')
          .select('id')
          .eq('name', name)
          .maybeSingle();

      if (existing != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Une league avec ce nom existe déjà !')),
        );
        return;
      }

      // Créer la league si aucun doublon
      final inserted = await supabase.from('leagues').insert({
        'name': name,
        'users_id': [widget.uid],
      });

      _leagueNameController.clear();
      _loadLeagues();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('League créée !')),
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
      if (league == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('League introuvable')),
        );
        return;
      }

      final leagueId = league['id']; // <-- récupère l'ID ici
      List users = List.from(league['users_id'] ?? []);
      if (!users.contains(widget.uid)) users.add(widget.uid);

      // Mettre à jour la league
      await supabase
          .from('leagues')
          .update({'users_id': users})
          .eq('id', leagueId);

      // Mettre à jour le tableau leagues dans usersdata
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
        const SnackBar(content: Text('Vous avez rejoint la league !')),
      );
    } catch (e) {
      debugPrint('Erreur join league: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text('Mes Leagues'),
        centerTitle: true,
        backgroundColor: cardBg,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Créer une league', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _leagueNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nom de la league',
                      hintStyle: TextStyle(color: textSecondary),
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cardBorder),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _createLeague,
                  style: ElevatedButton.styleFrom(backgroundColor: accentPrimary),
                  child: const Text('Créer'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Rejoindre une league', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _joinLeagueController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'ID de la league',
                      hintStyle: TextStyle(color: textSecondary),
                      filled: true,
                      fillColor: cardBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: cardBorder),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _joinLeague,
                  style: ElevatedButton.styleFrom(backgroundColor: accentPrimary),
                  child: const Text('Rejoindre'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Mes leagues', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: myLeagues.length,
                itemBuilder: (context, index) {
                  final league = myLeagues[index];
                  return Card(
                    color: cardBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: cardBorder)),
                    child: ListTile(
                      title: Text(league['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('ID: ${league['id']}', style: TextStyle(color: textSecondary)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
