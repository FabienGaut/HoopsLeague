import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:HoopsBets/pages/sign_in_page.dart';
import 'package:HoopsBets/l10n/app_localizations.dart';

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
    final parsedAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final currentPoints = (userData?['points'] ?? 0).toDouble();

    if (parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.invalidAmount),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (parsedAmount > currentPoints) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.notEnoughPoints),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await supabase.from('bets').insert({
        'user_id': widget.uid,
        'games_id': widget.bets.map((b) => b['game_id']).toList(),
        'odd': combinedOdd,
        'points_betted': parsedAmount.toInt(),
        'selection': widget.bets.map((b) => b['pickedTeam']).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      await supabase
          .from('usersdata')
          .update({'points': (currentPoints - parsedAmount).toInt()})
          .eq('id', widget.uid);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.successfulBet),
          backgroundColor: Colors.green,
        ),
      );

      setState(() => widget.bets.clear());
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorSendingBet),
          backgroundColor: Colors.red,
        ),
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

  // 🔹 Reprend le bouton “verre” de SignInPage
  Widget _buildGlassButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required double width,
    required double height,
    double fontSize = 16,
  }) {
    return Container(

      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: fontSize * 1.2),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double buttonWidth = (screenWidth * 0.75).clamp(200, 340).toDouble();

    return Scaffold(

      body: Stack(
        children: [
          // Dégradé violet-noir
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade900, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),

          SafeArea(
            child: Column(
              children: [
                // 🔹 Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),

                  child: Row(

                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Image.asset("assets/images/logo.png", height: 40),
                      const SizedBox(width: 8),
                      const Text(
                        "HoopsLeague",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: widget.bets.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            color: Colors.white.withOpacity(0.6),
                            size: 60),
                        const SizedBox(height: 12),
                        Text(
                          AppLocalizations.of(context)!.noBetsSelected,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.bets.length,
                    itemBuilder: (context, index) {
                      final bet = widget.bets[index];
                      final pickedTeam = bet['pickedTeam'];
                      final odd = bet['odd'] is int
                          ? (bet['odd'] as int).toDouble()
                          : bet['odd'] as double;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pickedTeam,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .oddAndStartTime(
                                      odd,
                                      bet['start_time'].toString(),
                                    ),
                                    style: TextStyle(
                                      color:
                                      Colors.white.withOpacity(0.7),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  odd.toStringAsFixed(2),
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () => _removeBet(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                if (widget.bets.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      border: Border(
                        top: BorderSide(
                            color: Colors.white.withOpacity(0.2), width: 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .combinedOdd(combinedOdd.toStringAsFixed(2)),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText:
                            AppLocalizations.of(context)!.totalAmount,
                            hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.6)),
                            prefixIcon: const Icon(Icons.attach_money,
                                color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(color: Colors.white),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        _buildGlassButton(
                          label:
                          AppLocalizations.of(context)!.payout(totalPayout),
                          icon: Icons.sports_basketball,
                          onPressed: _sendBetToSupabase,
                          width: buttonWidth,
                          height: 55,
                        ),
                      ],
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
