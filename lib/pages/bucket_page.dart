import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hoopsleague/l10n/app_localizations.dart';
import 'package:hoopsleague/services/clock.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hoopsleague/theme/utils.dart';
import 'package:hoopsleague/services/cache_service.dart';
import '../theme/app_colors.dart';
import '../utils/no_special_characters_formatter.dart';
import 'package:intl/intl.dart';
import 'app_state.dart';

final supabase = Supabase.instance.client;

class BucketPage extends StatefulWidget {
  final List<Map<String, dynamic>> bets;
  final String uid;
  final VoidCallback? onClose;
  final VoidCallback? onBetPlaced;
  final void Function(int index)? onBetRemoved;

  const BucketPage({super.key, required this.bets, required this.uid, this.onClose, this.onBetPlaced, this.onBetRemoved});

  @override
  State<BucketPage> createState() => _BucketPageState();
}

class _BucketPageState extends State<BucketPage> {
  final TextEditingController _amountController = TextEditingController();
  bool isLoading = true;
  bool _isCombinedBet = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => isLoading = false);
    });
  }

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
    if (_isCombinedBet) {
      return double.parse((amount * combinedOdd).toStringAsFixed(2));
    } else {
      double total = 0.0;
      for (var bet in widget.bets) {
        final odd = bet['odd'] is int ? (bet['odd'] as int).toDouble() : bet['odd'] as double;
        total += amount * odd;
      }
      return double.parse(total.toStringAsFixed(2));
    }
  }

  double get totalBetAmount {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (_isCombinedBet) {
      return amount;
    } else {
      return amount * widget.bets.length;
    }
  }

  Future<void> _sendBetToSupabase() async {
    final ctx = context.read<Clock>();
    final gameIds = widget.bets.map((bet) => bet['game_id'] as String? ?? '').toList();
    final parsedAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (widget.uid.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.uidError), backgroundColor: AppColors.error),
      );
      return;
    }

    if (parsedAmount <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.invalidAmount), backgroundColor: AppColors.error),
      );
      return;
    }

    try {
      final upcomingGames = await supabase.from('upcoming_scheduled_games').select('id').inFilter('id', gameIds);
      final upcomingGameIds = upcomingGames.map((g) => g['id'] as String).toSet();

      for (final gameId in gameIds) {
        if (!upcomingGameIds.contains(gameId)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.gameAlreadyStarted), backgroundColor: AppColors.error),
          );
          return;
        }
      }

      final pointsBetted = parsedAmount.toInt();

      if (!mounted) return;
      final appState = context.read<AppState>();
      final userData = appState.userData;

      if (userData == null) {
        await appState.loadUserData(widget.uid);
        final refreshedData = appState.userData;
        if (refreshedData == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: impossible de charger vos données.'), backgroundColor: AppColors.error),
          );
          return;
        }
      }

      final currentPoints = (appState.userData?['points'] ?? 0).toDouble();
      final totalPointsNeeded = totalBetAmount;

      if (totalPointsNeeded > currentPoints) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.notEnoughPoints), backgroundColor: AppColors.error),
        );
        return;
      }

      final now = ctx.now();

      if (_isCombinedBet) {
        final betData = {
          'user_id': widget.uid,
          'games_id': gameIds,
          'odd': combinedOdd,
          'points_betted': pointsBetted,
          'selection': widget.bets.map((b) => b['pickedTeam'] ?? '').toList(),
          'timestamp': now.toIso8601String(),
        };
        await supabase.from('bets').insert(betData);
      } else {
        for (var bet in widget.bets) {
          final gameId = bet['game_id'] as String? ?? '';
          final odd = bet['odd'] is int ? (bet['odd'] as int).toDouble() : bet['odd'] as double;
          final selection = bet['pickedTeam'] ?? '';
          final singleBetData = {
            'user_id': widget.uid,
            'games_id': [gameId],
            'odd': odd,
            'points_betted': pointsBetted,
            'selection': [selection],
            'timestamp': now.toIso8601String(),
          };
          await supabase.from('bets').insert(singleBetData);
        }
      }

      final double newPoints = (currentPoints - totalPointsNeeded);
      await supabase.from('usersdata').update({'points': newPoints.toInt()}).eq('id', widget.uid);
      await CacheService.savePointsToHistory(widget.uid, newPoints);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.successfulBet), backgroundColor: AppColors.success, duration: const Duration(seconds: 2)),
      );

      setState(() => widget.bets.clear());
      await appState.refreshUserData();

      if (widget.onClose != null) {
        widget.onClose!();
      } else {
        if (mounted) Navigator.pop(context);
      }

      if (widget.onBetPlaced != null) widget.onBetPlaced!();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.errorSendingBet}: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _removeBet(int index) {
    widget.onBetRemoved?.call(index);
    setState(() => widget.bets.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.betDeleted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textSecondary),
          onPressed: () {
            if (widget.onClose != null) {
              widget.onClose!();
            } else {
              Navigator.pop(context, widget.bets);
            }
          },
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              Image.asset(AppColors.logoAsset, height: kToolbarHeight * 0.5),
              SizedBox(width: kToolbarHeight * 0.15),
              Text("HoopsLeague", style: TextStyle(color: AppColors.textPrimary, fontSize: kToolbarHeight * 0.38, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: widget.bets.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, color: AppColors.textTertiary, size: 64),
                    const SizedBox(height: 16),
                    Text(t.noBetsSelected, style: TextStyle(fontSize: logScale(context, 18), color: AppColors.textSecondary)),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  children: [
                    ...List.generate(widget.bets.length, (index) {
                      final bet = widget.bets[index];
                      final betOdd = (bet['odd'] is int) ? (bet['odd'] as int).toDouble() : (bet['odd'] as double);
                      final convertedOdd = appState.convertOdds(betOdd);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderDark, width: 1),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(bet['pickedTeam'], style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 16), fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${t.odd}: $convertedOdd | ${formatIsoDateWithLocale(context, bet['start_time'].toString())}',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 12)),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(convertedOdd, style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600, fontSize: logScale(context, 15))),
                                ),
                                IconButton(icon: Icon(Icons.delete_outline, color: AppColors.error), onPressed: () => _removeBet(index)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderDark, width: 1),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(color: AppColors.surfaceHover, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isCombinedBet = true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _isCombinedBet ? AppColors.primaryBlue : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        t.combinedBet,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: _isCombinedBet ? Colors.white : AppColors.textSecondary,
                                          fontWeight: _isCombinedBet ? FontWeight.w600 : FontWeight.w400,
                                          fontSize: logScale(context, 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _isCombinedBet = false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: !_isCombinedBet ? AppColors.primaryBlue : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        t.singleBet,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: !_isCombinedBet ? Colors.white : AppColors.textSecondary,
                                          fontWeight: !_isCombinedBet ? FontWeight.w600 : FontWeight.w400,
                                          fontSize: logScale(context, 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (_isCombinedBet)
                            Text(t.combinedOdd(appState.convertOdds(combinedOdd)), style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: logScale(context, 16)))
                          else
                            Text('${widget.bets.length} ${t.singleBet.toLowerCase()}', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: logScale(context, 16))),
                          const SizedBox(height: 16),

                          TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, NoSpecialCharactersFormatter()],
                            style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 16)),
                            decoration: InputDecoration(
                              labelText: _isCombinedBet ? t.totalAmount : '${t.totalAmount} (${t.perBet})',
                              labelStyle: TextStyle(color: AppColors.textSecondary),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.borderDark), borderRadius: BorderRadius.circular(8)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.primaryBlue), borderRadius: BorderRadius.circular(8)),
                              prefixIcon: Icon(Icons.add_circle_outline, color: AppColors.textSecondary),
                              suffixText: !_isCombinedBet && widget.bets.length > 1 ? 'x${widget.bets.length} = ${totalBetAmount.toInt()}' : null,
                              suffixStyle: TextStyle(color: AppColors.textSecondary),
                              filled: true,
                              fillColor: AppColors.surfaceHover,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _sendBetToSupabase,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                              child: Text(t.payout(totalPayout), style: TextStyle(fontWeight: FontWeight.w600, fontSize: logScale(context, 16), color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
