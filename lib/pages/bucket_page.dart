import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hoopsleague/l10n/app_localizations.dart';
import 'package:hoopsleague/services/clock.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hoopsleague/services/cache_service.dart';
import 'package:hoopsleague/theme/utils.dart';
import '../theme/app_colors.dart';
import '../theme/widgets_theme.dart';
import '../utils/no_special_characters_formatter.dart';
import '../utils/security_utils.dart';
import 'package:intl/intl.dart';

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

  // 🎨 Palette du thème cohérente avec LeaderboardPage
  static const Color accentPrimary = Color(0xFF256af4);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color surfaceDark = Color(0xFF182134);
  static const Color backgroundDark = Color(0xFF101622);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final messenger = ScaffoldMessenger.of(context);
    
    // Security: Validate user ID
    try {
      SecurityUtils.requireCurrentUser(widget.uid);
    } catch (e) {
      setState(() => isLoading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.unauthorizedAccess),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      final data = await supabase
          .from('usersdata')
          .select()
          .eq('id', widget.uid)
          .single();

      if (!mounted) return; // <-- évite le crash
        setState(() {
          userData = data;
          isLoading = false;
        });
    } catch (e) {
      setState(() => isLoading = false);
      messenger.showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.userLoadingError}: $e')),
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

  String formatIsoDateWithLocale(BuildContext context, String isoDate, {String format = 'EEEE, dd/MM/yyyy – HH:mm'}) {
    try {
      DateTime parsedDate = DateTime.parse(isoDate).toLocal();
      final locale = Localizations.localeOf(context).toString();
      return DateFormat(format, locale).format(parsedDate);
    } catch (e) {
      return isoDate;
    }
  }

  double get totalPayout {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    return double.parse((amount * combinedOdd).toStringAsFixed(2));
  }

  Future<void> _sendBetToSupabase() async {
    final ctx = context.read<Clock>();
    final gameIds =  widget.bets.map((bet) => bet['game_id'] as String? ?? '').toList();
    final parsedAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    // Security: Validate user ID
    try {
      SecurityUtils.requireCurrentUser(widget.uid);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.unauthorizedAccess),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.uidError), backgroundColor: Colors.red),
      );
      return;
    }

    if (parsedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invalidAmount),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final pointsBetted = parsedAmount.toInt();

      final currentPoints = (userData?['points'] ?? 0).toDouble();

      if (parsedAmount > currentPoints) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.notEnoughPoints),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await supabase.from('bets').insert({
        'user_id': widget.uid,
        'games_id': gameIds,
        'odd': combinedOdd,
        'points_betted': pointsBetted,
        'selection': widget.bets.map((b) => b['pickedTeam'] ?? '').toList(),
        'timestamp': context.read<Clock>().now().toIso8601String(),
      });

      final double newPoints = (currentPoints - parsedAmount);

      await supabase
          .from('usersdata')
          .update({'points': newPoints.toInt()})
          .eq('id', widget.uid);
      await CacheService.saveUserPoints(
          widget.uid, newPoints, ctx.now());

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
      debugPrint(e.toString());
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context, widget.bets),
        ),
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
                colors: [Color(0xFF314368), Color(0xFF182134)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.3)),
          SafeArea(
          child:
          Column(
            children: [
              Expanded(
                child: widget.bets.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t.noBetsSelected,
                        style:  TextStyle(
                            fontSize: logScale(context, 26), color: textSecondary),
                      ),
                      const Icon(Icons.shopping_cart,
                          color: Colors.grey, size: 36),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.bets.length,
                  itemBuilder: (context, index) {
                    final bet = widget.bets[index];

                    return HoopsCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 🏀 Infos sur le pari
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bet['pickedTeam'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: logScale(context, 18),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  t.oddAndStartTime(
                                    bet['odd'],
                                    formatIsoDateWithLocale(context, bet['start_time'].toString()),
                                  ),
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: logScale(context, 13),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 🎯 Cote et bouton supprimer
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF222F49),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.accentPrimary, width: 1),
                                ),
                                child: Text(
                                  bet['odd'].toStringAsFixed(2),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: logScale(context, 15),
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
                    );


                  },
                ),
              ),
              if (widget.bets.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: surfaceDark, width: 0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        t.combinedOdd(combinedOdd.toStringAsFixed(2)),
                        style:  TextStyle(
                          color: textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: logScale(context, 16),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _amountController,
                        keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          NoSpecialCharactersFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: t.totalAmount,
                          labelStyle: const TextStyle(color: textSecondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.25)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: accentPrimary),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.attach_money,
                              color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
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
                            t.payout(totalPayout),
                            style:  TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: logScale(context, 18),
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
          )
        ],
      ),
    );
  }
}
