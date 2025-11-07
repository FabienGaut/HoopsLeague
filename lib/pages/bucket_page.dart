import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:HoopsBets/pages/sign_in_page.dart';
import 'package:HoopsBets/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // Couleurs du thème sombre
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color cardBorder = Color(0xFF2A2A2A);
  static const Color accentPrimary = Colors.deepPurple;
  static const Color accentGold = Color(0xFFFFD700);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color successGreen = Color(0xFF4CAF50);



  @override
  void initState() {
    super.initState();
    _loadUserData();
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
         SnackBar(content: Text(AppLocalizations.of(context)!.invalidAmount), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final pointsBetted = parsedAmount.toInt();
      final currentPoints = (userData?['points'] ?? 0).toDouble();

// ✅ Vérifie si le joueur a assez de points
      if (parsedAmount > currentPoints) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:  Text(AppLocalizations.of(context)!.notEnoughPoints),
            backgroundColor: Colors.red,
          ),
        );

      }

      await supabase.from('bets').insert({
        'user_id': widget.uid,
        'games_id': gameIds,
        'odd': combinedOdd,
        'points_betted': pointsBetted,
        'selection': widget.bets.map((b) => b['pickedTeam'] ?? '').toList(),
        'timestamp': DateTime.now().toIso8601String(),
      });


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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorSendingBet), backgroundColor: Colors.red),
      );
    }
  }

  void _removeBet(int index) {
    setState(() {
      widget.bets.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(AppLocalizations.of(context)!.betDeleted)),
    );
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
            Image.asset('assets/images/logo.png', height: 30),
            const SizedBox(width: 8),
            const Text("HoopsLeague", style: TextStyle(color: Colors.white),),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, widget.bets),
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

                return Container(
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
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppLocalizations.of(context)!.oddAndStartTime(
                                  odd,
                                  bet['start_time'].toString(),
                                ),
                                style: const TextStyle(fontSize: 13, color: textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: accentPrimary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: accentPrimary, width: 1),
                              ),
                              child: Text(
                                odd.toStringAsFixed(2),
                                style: const TextStyle(
                                  color: accentPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
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
                color: cardBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.combinedOdd(combinedOdd.toStringAsFixed(2)),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.totalAmount,
                      labelStyle: const TextStyle(color: textSecondary),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: cardBorder),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: accentPrimary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.attach_money, color: Colors.white70 ),
                      filled: true,
                      fillColor: cardBg,
                    ),
                    style: const TextStyle(color: textPrimary),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _sendBetToSupabase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.payout(totalPayout),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
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
