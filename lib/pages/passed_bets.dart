import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';

final supabase = Supabase.instance.client;

class MyBetsPage extends StatefulWidget {
  final String uid;

  const MyBetsPage({super.key, required this.uid});

  @override
  State<MyBetsPage> createState() => _MyBetsPageState();
}

class _MyBetsPageState extends State<MyBetsPage> {
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> bets = [];
  bool isLoadingUser = true;
  bool isLoadingBets = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _listenToBets();
  }

  Future<void> _loadUserData() async {
    try {
      final response = await supabase
          .from('UserData')
          .select()
          .eq('id', widget.uid)
          .single();

      setState(() {
        userData = response;
        isLoadingUser = false;
      });
    } catch (e) {
      setState(() => isLoadingUser = false);
    }
  }

  void _listenToBets() {
    final stream = supabase
        .from('bets')
        .stream(primaryKey: ['id'])
        .eq('user_id', widget.uid)
        .order('timestamp', ascending: false);

    stream.listen((data) {
      setState(() {
        bets = List<Map<String, dynamic>>.from(data);
        isLoadingBets = false;
      });
    });
  }

  double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.title ?? "My Bets",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header avec le solde utilisateur
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.blue[700]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: isLoadingUser
                ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
                : Column(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Your Balance",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${userData?['points'] ?? 0}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  "POINTS",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),

          // Liste des paris
          Expanded(
            child: isLoadingBets
                ? const Center(child: CircularProgressIndicator())
                : bets.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_basketball,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)?.noBetsSelected ??
                        "No bets found",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: bets.length,
              itemBuilder: (context, index) {
                final bet = bets[index];
                final amount = parseDouble(bet['points_betted']);
                final odd = parseDouble(bet['odd']);
                final payout = (amount * odd).toStringAsFixed(2);

                final startTime = DateTime.tryParse(
                    bet['timestamp']?.toString() ?? '') ??
                    DateTime.now();

                final status = bet['status'] ?? 'pending';
                Color statusColor;
                IconData statusIcon;

                switch (status) {
                  case 'won':
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle;
                    break;
                  case 'lost':
                    statusColor = Colors.red;
                    statusIcon = Icons.cancel;
                    break;
                  default:
                    statusColor = Colors.orange;
                    statusIcon = Icons.access_time;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Icon(
                                statusIcon,
                                color: statusColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bet['pickedTeam'] ?? "",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat.yMd()
                                        .add_jm()
                                        .format(startTime),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                "Odd",
                                odd.toStringAsFixed(2),
                                Colors.blue,
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.grey[300],
                              ),
                              _buildStatItem(
                                "Bet",
                                amount.toStringAsFixed(0),
                                Colors.orange,
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.grey[300],
                              ),
                              _buildStatItem(
                                "Payout",
                                payout,
                                Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
