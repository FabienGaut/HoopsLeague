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

  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color cardBorder = Color(0xFF2A2A2A);
  static const Color accentPrimary = Color(0xFF8551CF);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color successGreen = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _listenToBets();
  }

  Future<void> _loadUserData() async {
    try {
      final response = await supabase
          .from('usersdata')
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
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title:  Text(
          AppLocalizations.of(context)?.myBets ?? "My Bets",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: cardBg,
              border: Border(
                bottom: BorderSide(color: cardBorder, width: 1),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: isLoadingUser
                ? const Center(
                child: CircularProgressIndicator(color: accentPrimary))
                : Column(
              children: [
                const Icon(Icons.account_balance_wallet,
                    color: accentPrimary, size: 40),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)?.yourBalance ?? "Your Balance",
                  style: TextStyle(
                      color: textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  "${userData?['points'] ?? 0}",
                  style: const TextStyle(
                    color: accentGold,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  "POINTS",
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoadingBets
                ? const Center(
                child: CircularProgressIndicator(color: accentPrimary))
                : bets.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_basketball,
                      size: 80, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)?.noBetsSelected ??
                        "No bets found",
                    style: const TextStyle(
                        fontSize: 16,
                        color: textSecondary,
                        fontWeight: FontWeight.w500),
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
                final startTime =
                    DateTime.tryParse(bet['timestamp']?.toString() ?? '') ??
                        DateTime.now();

                final status = bet['status'] ?? 'pending';
                Color statusColor;
                IconData statusIcon;

                switch (status) {
                  case 'won':
                    statusColor = successGreen;
                    statusIcon = Icons.check_circle;
                    break;
                  case 'lost':
                    statusColor = Colors.redAccent;
                    statusIcon = Icons.cancel;
                    break;
                  default:
                    statusColor = Colors.orangeAccent;
                    statusIcon = Icons.access_time;
                }

                final List<dynamic> selections =
                (bet['selection'] ?? []) as List<dynamic>;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
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
                                color: statusColor.withOpacity(0.2),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Icon(
                                statusIcon,
                                color: statusColor,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bet['pickedTeam'] ?? "Multiple Bet",
                                    style: const TextStyle(
                                      color: textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat.yMd()
                                        .add_jm()
                                        .format(startTime),
                                    style: const TextStyle(
                                      color: textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Liste des équipes sélectionnées
                        if (selections.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: selections.map((team) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: accentPrimary.withOpacity(0.15),
                                  border: Border.all(
                                      color: accentPrimary, width: 1),
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: Text(
                                  team.toString(),
                                  style: const TextStyle(
                                    color: accentPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cardBorder.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(AppLocalizations.of(context)?.odd ?? "Odds",
                                  odd.toStringAsFixed(2), accentPrimary),
                              _divider(),
                              _buildStatItem(AppLocalizations.of(context)?.amount ?? "Amount",
                                  amount.toStringAsFixed(0), accentGold),
                              _divider(),
                              _buildStatItem(
                                  AppLocalizations.of(context)?.payoutText ?? "Payout",
                                  payout, successGreen),
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

  Widget _divider() => Container(
    height: 40,
    width: 1,
    color: cardBorder,
  );

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
