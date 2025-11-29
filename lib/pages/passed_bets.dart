import 'package:flutter/material.dart';
import 'package:hoopsleague/services/clock.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/utils.dart';
import '../utils/security_utils.dart';

final supabase = Supabase.instance.client;

class MyBetsPage extends StatefulWidget {
  final String uid;
  const MyBetsPage({super.key, required this.uid});

  @override
  State<MyBetsPage> createState() => _MyBetsPageState();
}

class _MyBetsPageState extends State<MyBetsPage> {
  bool _initialized = false;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> bets = [];
  bool isLoadingUser = true;
  bool isLoadingBets = true;

  // 🎨 Palette cohérente avec LeaderboardPage
  static const Color accentPrimary = Color(0xFF256af4);
  static const Color accentGlow = Color(0xFF9C9CFF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color successGreen = Color(0xFF4CAF50);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _loadUserData(); // Ici c’est safe
    }
  }


  @override
  void initState() {
    super.initState();
   // _loadUserData();
    _listenToBets();
  }

  Future<void> _loadUserData() async {
    final messenger = ScaffoldMessenger.of(context);

    // Security: Validate user ID
    try {
      SecurityUtils.requireCurrentUser(widget.uid);
    } catch (e) {
      setState(() => isLoadingUser = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.unauthorizedAccess),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown, // rétrécit si nécessaire
          child: Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: kToolbarHeight * 0.6, // proportion de l’AppBar
              ),
              SizedBox(width: kToolbarHeight * 0.2),
              Text(
                "HoopsLeague",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: kToolbarHeight * 0.4, // proportion de l’AppBar
                ),
              ),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          // 🌌 Dégradé violet → noir
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF314368), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.3)),

          SafeArea(
            child: Column(
              children: [
                // 💰 Carte du solde utilisateur
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF182134),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 24),
                    child: isLoadingUser
                        ? const Center(
                        child:
                        CircularProgressIndicator(color: accentPrimary))
                        : Column(
                      children: [
                        const Icon(Icons.account_balance_wallet,
                            color: accentGlow, size: 42),
                        const SizedBox(height: 10),
                        Text(
                          t.yourBalance,
                          style:  TextStyle(
                              color: textSecondary, fontSize: logScale(context, 15)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${userData?['points'] ?? 0}",
                          style: const TextStyle(
                            color: accentGlow,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          "POINTS",
                          style:  TextStyle(
                            color: textSecondary,
                            fontSize: logScale(context, 13),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 📜 Liste des paris
                Expanded(
                  child: isLoadingBets
                      ? const Center(
                      child:
                      CircularProgressIndicator(color: accentPrimary))
                      : bets.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sports_basketball,
                            size: 80, color: Colors.white38),
                        const SizedBox(height: 16),
                        Text(
                          t.noBetsSelected,
                          style:  TextStyle(
                              fontSize: logScale(context, 16),
                              color: textSecondary,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    itemCount: bets.length,
                    itemBuilder: (context, index) {
                      final bet = bets[index];
                      final amount =
                      parseDouble(bet['points_betted']);
                      final odd = parseDouble(bet['odd']);
                      final payout =
                      (amount * odd).toStringAsFixed(2);
                      final startTime =
                          DateTime.tryParse(bet['timestamp'] ?? '') ??
                              context.read<Clock>().now();

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
                        margin:
                        const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF182134),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color:
                              Colors.white.withValues(alpha: 0.15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding:
                                    const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: statusColor
                                          .withValues(alpha: 0.2),
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
                                        if (selections.length > 1)
                                          Text(
                                          AppLocalizations.of(context)!.multipleBets,
                                          style: TextStyle(
                                            color: textPrimary,
                                            fontSize: logScale(context, 18),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                        else
                                        Text(
                                        bet['pickedTeam'] ?? AppLocalizations.of(context)!.singleBet,
                                        style: TextStyle(
                                          color: textPrimary,
                                          fontSize: logScale(context, 18),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),



                      const SizedBox(height: 4),
                                        Text(
                                          DateFormat.yMd()
                                              .add_jm()
                                              .format(startTime),
                                          style:  TextStyle(
                                            color: textSecondary,
                                            fontSize: logScale(context, 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (selections.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: selections.map((team) {
                                    return Container(
                                      padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6),
                                      decoration: BoxDecoration(
                                        color: accentGlow
                                            .withValues(alpha: 0.1),
                                        border: Border.all(
                                            color: accentGlow
                                                .withValues(alpha: 0.4),
                                            width: 1),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        team.toString(),
                                        style:  TextStyle(
                                          color: accentGlow,
                                          fontSize: logScale(context, 14),
                                          fontWeight:
                                          FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(alpha: 0.05),
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceAround,
                                  children: [
                                    _buildStatItem(
                                        t.odd,
                                        odd.toStringAsFixed(2),
                                        accentGlow),
                                    _divider(),
                                    _buildStatItem(t.amount,
                                        amount.toStringAsFixed(0), Colors.amberAccent),
                                    _divider(),
                                    _buildStatItem(t.payoutText,
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
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    height: 40,
    width: 1,
    color: Colors.white.withValues(alpha: 0.15),
  );

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style:  TextStyle(color: textSecondary, fontSize: logScale(context, 12))),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: logScale(context, 16),
          ),
        ),
      ],
    );
  }
}
