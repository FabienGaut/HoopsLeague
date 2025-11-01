import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:HoopsBets/pages/sign_in_page.dart';
import 'package:HoopsBets/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:HoopsBets/pages/bet_cache.dart';

final supabase = Supabase.instance.client;

class BucketPage extends StatefulWidget {
  final List<Map<String, dynamic>> bets;
  final String uid;

  const BucketPage({super.key, required this.bets, required this.uid});

  @override
  State<BucketPage> createState() => _BucketPageState();
}

class _BucketPageState extends State<BucketPage> {
  final TextEditingController _amountController = TextEditingController();
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCachedBets();
  }
  Future<void> _loadCachedBets() async {
    final cachedBets = await BetCache.loadBets();
    if (cachedBets.isNotEmpty) {
      setState(() {
        widget.bets.addAll(cachedBets);
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
        SnackBar(content: Text('Erreur chargement utilisateur: $e')),
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

  double get combinedOdd {
    double prod = 1.0;
    for (var bet in widget.bets) {
      final odd = bet['odd'] is int
          ? (bet['odd'] as int).toDouble()
          : bet['odd'] as double;
      prod *= odd;
    }
    return prod;
  }

  double get totalPayout {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    return double.parse((amount * combinedOdd).toStringAsFixed(2));
  }

  Future<void> _sendBetToSupabase() async {
    final gameIds = widget.bets.map((bet) => bet['game_id'] as String? ?? '').toList();
    final parsedAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (widget.uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ UID Error !"), backgroundColor: Colors.red),
      );
      return;
    }

    if (parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Invalid amount."), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final pointsBetted = parsedAmount.toInt();
      await supabase.from('bets').insert({
        'user_id': widget.uid,
        'games_id': gameIds,
        'odd': combinedOdd,
        'points_betted': pointsBetted,
        'selection': widget.bets.map((b) => b['pickedTeam'] ?? '').toList(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      await BetCache.saveBets(widget.bets);
      final currentPoints = (userData?['points'] ?? 0).toDouble();
      final newPoints = (currentPoints - parsedAmount).toInt();

      await supabase.from('usersdata').update({'points': newPoints}).eq('id', widget.uid);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.successfulBet),
          backgroundColor: Colors.green,
        ),
      );

      setState(() => widget.bets.clear());
      Navigator.pop(context);
      _loadUserData();
    } catch (e) {
      if (kDebugMode) print('Erreur envoi pari: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur envoi pari: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _removeBet(int index) {
    setState(() {
      widget.bets.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pari supprimé du panier.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, widget.bets),
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            if (isLoading) const LinearProgressIndicator(),
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
              leading: const Icon(Icons.access_time),
              title: Text('Timezone : ${userData?['timezone'] ?? 'N/A'}'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: Text(AppLocalizations.of(context)!.reloadData),
              onTap: _loadUserData,
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(AppLocalizations.of(context)!.logout,
                  style: const TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: widget.bets.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.noBetsSelected,
                    style: TextStyle(fontSize: 26, color: Colors.grey[700]),
                  ),
                  const Icon(Icons.shopping_cart, color: Colors.grey, size: 36),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.bets.length,
              itemBuilder: (context, index) {
                final bet = widget.bets[index];
                final pickedTeam = bet['pickedTeam'];
                final odd = bet['odd'] is int
                    ? (bet['odd'] as int).toDouble()
                    : bet['odd'] as double;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: Colors.black26,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pickedTeam,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppLocalizations.of(context)!.oddAndStartTime(
                                  odd,
                                  bet['start_time'].toString(),
                                ),
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                odd.toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _removeBet(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          if (widget.bets.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      AppLocalizations.of(context)!
                          .combinedOdd(combinedOdd.toStringAsFixed(2)),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  TextField(
                    controller: _amountController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.totalAmount,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blueAccent),
                      ),
                      prefixIcon:
                      const Icon(Icons.attach_money, color: Colors.blueAccent),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _sendBetToSupabase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.payout(totalPayout),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
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
