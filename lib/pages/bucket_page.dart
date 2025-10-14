import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BucketPage extends StatefulWidget {
  final List<Map<String, dynamic>> bets;

  const BucketPage({super.key, required this.bets});

  @override
  State<BucketPage> createState() => _BucketPageState();
}

class _BucketPageState extends State<BucketPage> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get combinedOdd {
    double prod = 1.0;
    for (var bet in widget.bets) {
      final odd = bet['odd'] is int ? (bet['odd'] as int).toDouble() : bet['odd'] as double;
      prod *= odd;
    }
    return prod;
  }

  double get totalPayout {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    return amount * combinedOdd;
  }

  Future<void> _sendBetToFirebase() async {
    final gameIds = widget.bets.map((bet) => bet['game_id'] as String? ?? '').toList();
    try {
      await FirebaseFirestore.instance.collection("Bets").add({
        'user_id': '',
        'games_id': gameIds,
        'odd': combinedOdd.toDouble(),
        'points_betted':
        double.tryParse(_amountController.text.trim()) ?? 0.0,
        'selection':
        widget.bets.map((bet) => bet['pickedTeam'] as String? ?? '').toList(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text("Pari enregistré dans la base ✅ "),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur d’envoi à Firestore : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            Image.asset(
              'assets/images/logo.jpeg',
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text("HoopsBets")
          ],
        ),

      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: widget.bets.length,
              itemBuilder: (context, index) {
                final bet = widget.bets[index];
                final pickedTeam = bet['pickedTeam'];
                final odd = bet['odd'] is int ? (bet['odd'] as int).toDouble() : bet['odd'] as double;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  shadowColor: Colors.black26,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pickedTeam,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Odd: $odd  |  Starts at: ${bet['start_time']}",
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            odd.toStringAsFixed(2),
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        )
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
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Montant total",
                      labelStyle: const TextStyle(color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blueAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blueAccent),
                      ),
                      fillColor: Colors.grey[100],
                      filled: true,
                      prefixIcon: const Icon(Icons.attach_money, color: Colors.blueAccent),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _sendBetToFirebase,
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
                        "Gain potentiel: ${totalPayout.toStringAsFixed(2)}",
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
