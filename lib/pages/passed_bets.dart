import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

class MyBetsPage extends StatefulWidget {
  final String uid;

  const MyBetsPage({super.key, required this.uid});

  @override
  State<MyBetsPage> createState() => _MyBetsPageState();
}

class _MyBetsPageState extends State<MyBetsPage> {

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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.title ?? "My Bets"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Bets')
            .where('user_id', isEqualTo: widget.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)?.noBetsSelected ?? "No bets found",
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          final bets = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bets.length,
            itemBuilder: (context, index) {
              final bet = bets[index].data() as Map<String, dynamic>;

              final amount = parseDouble(bet['points_betted']);
              final odd = parseDouble(bet['odd']);
              final payout = (amount * odd).toStringAsFixed(2);

              final startTime = (bet['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

              // Pour afficher home/away teams si disponibles
              final homeTeam = bet['home_team'] ?? bet['pickedTeam'];
              final awayTeam = bet['away_team'] ?? "";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                shadowColor: Colors.black26,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (homeTeam.isNotEmpty)
                            Image.asset(
                              "assets/images/${homeTeam.split(' ').last}.png",
                              height: 32,
                              width: 32,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            homeTeam,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          const Text("vs", style: TextStyle(fontSize: 14, color: Colors.grey)),
                          const SizedBox(width: 6),
                          if (awayTeam.isNotEmpty)
                            Text(
                              awayTeam,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Odd: $odd"),
                          Text("Amount: $amount"),
                          Text("Payout: $payout"),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat.yMd().add_jm().format(startTime),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
