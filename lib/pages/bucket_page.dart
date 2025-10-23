import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:HoopsBets/pages/games_page.dart';
import 'package:HoopsBets/pages/sign_in_page.dart';
import 'package:HoopsBets/l10n/app_localizations.dart';


class BucketPage extends StatefulWidget {
  final List<Map<String, dynamic>> bets;
  final String uid;

  const BucketPage({super.key, required this.bets,  required this.uid});

  @override
  State<BucketPage> createState() => _BucketPageState();
}

class _BucketPageState extends State<BucketPage> {
  final TextEditingController _amountController = TextEditingController();
  Map<String, dynamic>? userData;
  bool isLoading = true;
  late final userPoints;

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
      final doc = await FirebaseFirestore.instance
          .collection('UserData')
          .doc(widget.uid)
          .get();

      if (doc.exists) {
        setState(() {
          userData = doc.data();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data not found !'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading user data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
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

    await FirebaseFirestore.instance
        .collection('UserData')
        .doc(widget.uid)
        .update({'points': newPoints});

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
    final payout = amount * combinedOdd;
    return double.parse(payout.toStringAsFixed(2));
  }

  Future<void> _sendBetToFirebase() async {
    final gameIds = widget.bets.map((bet) => bet['game_id'] as String? ?? '').toList();
    try {
      if (widget.uid.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ UID Error !"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.collection("Bets").add({
        'user_id': widget.uid,
        'games_id': gameIds,
        'odd': combinedOdd.toDouble(),
        'points_betted':
        double.tryParse(_amountController.text.trim()) ?? 0.0,
        'selection':
        widget.bets.map((bet) => bet['pickedTeam'] as String? ?? '').toList(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      final parsedAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      final currentPoints = (userData?['points'] ?? 0).toDouble();

      userPoints = currentPoints - parsedAmount;


      await FirebaseFirestore.instance

          .collection('UserData')
          .doc(widget.uid)
          .update({'points': userPoints}
      );


      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(AppLocalizations.of(context)!.successfulBet),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("UID Error ! , error : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      widget.bets.clear();
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GamesPage(uid: widget.uid,)),
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
            Image.asset(
              'assets/images/logo.jpeg',
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text("HoopsBets")
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {

              Navigator.pop(context);

          },
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            if (isLoading)
              const LinearProgressIndicator(), // petit indicateur
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
              title:  Text(AppLocalizations.of(context)!.reloadData),
              onTap: () {
                Navigator.pop(context); // ferme le drawer
                _loadUserData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(AppLocalizations.of(context)!.logout, style: const TextStyle(color: Colors.red)),
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
              child: Column (children: [

                Text(AppLocalizations.of(context)!.noBetsSelected,
                  style: TextStyle(fontSize: 26, color: Colors.grey[700]),
                ),
                Icon(Icons.shopping_cart, color: Colors.grey, size: 36),
          ]

              )

            )
                :
            ListView.builder(
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
                              AppLocalizations.of(context)!.oddAndStartTime(
                                odd,  // passe le double directement
                                bet['start_time'].toString(), // string
                              ),
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
                  if (widget.bets.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        AppLocalizations.of(context)!.combinedOdd(
                          combinedOdd.toStringAsFixed(2),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.totalAmount,
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
                        AppLocalizations.of(context)!.payout(
                          totalPayout,
                        ),
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
