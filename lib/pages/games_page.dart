import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/bucket_page.dart';
import 'package:intl/intl.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final List<Map<String, dynamic>> bets = [];
  final ValueNotifier<List<Map<String, dynamic>>> betsNotifier = ValueNotifier([]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        body:

        StreamBuilder(

          stream: FirebaseFirestore.instance.collection("GamesData").orderBy("start_time").snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return CircularProgressIndicator();
            }
            if(!snapshot.hasData){
              return Text("no data");
            }
            List<dynamic> games = [];
            snapshot.data!.docs.forEach((element) {
              games.add(element);
            });

            return  ListView.builder(
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                final homeTeam = game['home_team'];
                final awayTeam = game['away_team'];

                return Dismissible(
                  key: Key(game.id),
                  background: Container(
                    color: Colors.blueAccent, // swipe vers la droite → awayTeam ?
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red, // swipe vers la gauche → homeTeam ?
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
                        'game_id' : game['id']
                      };
                    } else {
                      selectedTeam = awayTeam;
                      betToAdd = {
                        'pickedTeam': awayTeam,
                        'odd': game['odd_away_team'],
                        'start_time': game['start_time'],
                        'game_id' : game['id']
                      };
                    }

                    // Ajouter le pari sans appeler setState
                    bets.add(betToAdd);
                    betsNotifier.value = [...betsNotifier.value, betToAdd]; // ajoute le pari

                    print("Pari sur : $selectedTeam");

                    // Retourne true pour supprimer la Card
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
                              Text("$homeTeam - $awayTeam",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                                child: Text("${game['odd_home_team']}",
                                    style: const TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text("${game['odd_away_team']}",
                                    style: const TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Starts at ${DateFormat.yMd().add_jm().format(DateTime.parse(game['start_time']).toLocal())}",
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

          } ,
      ),
      // Bouton de panier
      floatingActionButton: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: betsNotifier,
        builder: (context, bets, _) {
          return ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BucketPage(bets: bets)),
              );
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
