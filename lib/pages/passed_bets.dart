import 'package:flutter/material.dart';
import 'package:hoopsleague/services/clock.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/utils.dart';
import '../services/cache_service.dart';
import 'app_state.dart';

final supabase = Supabase.instance.client;

enum GraphScope { week, month, sixMonths, year, all }

class MyBetsPage extends StatefulWidget {
  final String uid;
  const MyBetsPage({super.key, required this.uid});

  @override
  State<MyBetsPage> createState() => _MyBetsPageState();
}

class _MyBetsPageState extends State<MyBetsPage> {
  bool _initialized = false;
  List<Map<String, dynamic>> bets = [];
  List<Map<String, dynamic>> pointsHistory = [];
  List<Map<String, dynamic>> fullHistory = [];
  GraphScope _selectedScope = GraphScope.month;
  bool isLoadingUser = true;
  bool isLoadingBets = true;
  bool isLoadingGraph = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      setState(() {
        isLoadingUser = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBets();
    _loadPointsHistory();
  }

  List<Map<String, dynamic>> _filterHistoryByScope(List<Map<String, dynamic>> history, GraphScope scope) {
    if (history.isEmpty || scope == GraphScope.all) {
      return history;
    }

    final now = DateTime.now();
    final cutoffDate = switch (scope) {
      GraphScope.week => now.subtract(const Duration(days: 7)),
      GraphScope.month => now.subtract(const Duration(days: 30)),
      GraphScope.sixMonths => now.subtract(const Duration(days: 180)),
      GraphScope.year => now.subtract(const Duration(days: 365)),
      GraphScope.all => DateTime(1970),
    };

    return history.where((entry) {
      final date = entry['date'] as DateTime;
      return date.isAfter(cutoffDate);
    }).toList();
  }

  void _onScopeChanged(GraphScope scope) {
    setState(() {
      _selectedScope = scope;
      pointsHistory = _filterHistoryByScope(fullHistory, scope);
    });
  }

  String _getScopeLabel(GraphScope scope) {
    return switch (scope) {
      GraphScope.week => '1S',
      GraphScope.month => '1M',
      GraphScope.sixMonths => '6M',
      GraphScope.year => '1A',
      GraphScope.all => 'Tout',
    };
  }

  Future<void> _loadPointsHistory() async {
    try {
      final history = await CacheService.loadPointsHistory(widget.uid).timeout(
        const Duration(seconds: 5),
        onTimeout: () => [],
      );

      if (!mounted) return;
      setState(() {
        fullHistory = history;
        pointsHistory = _filterHistoryByScope(history, _selectedScope);
        isLoadingGraph = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        fullHistory = [];
        pointsHistory = [];
        isLoadingGraph = false;
      });
    }
  }

  Future<void> _loadBets() async {
    try {
      final data = await supabase
          .from('bets')
          .select()
          .eq('user_id', widget.uid)
          .order('timestamp', ascending: false);

      if (!mounted) return;
      setState(() {
        bets = List<Map<String, dynamic>>.from(data);
        isLoadingBets = false;
      });
    } catch (e) {
      debugPrint('Error loading bets: $e');
      if (!mounted) return;
      setState(() {
        isLoadingBets = false;
      });
    }
  }

  Future<void> refreshBets() async {
    await _loadBets();
  }

  double parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Widget _buildPointsGraph() {
    final t = AppLocalizations.of(context)!;

    if (isLoadingGraph) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark, width: 1),
        ),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    if (pointsHistory.isEmpty) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark, width: 1),
        ),
        child: Center(
          child: Text(
            t.noData,
            style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 14)),
          ),
        ),
      );
    }

    return Container(
      height: 320,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            t.pointsEvolution,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: logScale(context, 16),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: GraphScope.values.map((scope) {
                final isSelected = _selectedScope == scope;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => _onScopeChanged(scope),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue.withValues(alpha: 0.15)
                            : AppColors.surfaceHover,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryBlue : AppColors.borderDark,
                        ),
                      ),
                      child: Text(
                        _getScopeLabel(scope),
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: logScale(context, 12),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.borderDark,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 100,
                      reservedSize: 35,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: logScale(context, 9),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (pointsHistory.length / 6).clamp(1, 10),
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= pointsHistory.length) {
                          return const SizedBox.shrink();
                        }
                        final date = pointsHistory[index]['date'] as DateTime;
                        return Text(
                          "${date.day}/${date.month}",
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: logScale(context, 9),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (pointsHistory.length - 1).toDouble(),
                minY: pointsHistory.map((e) => (e['points'] as num).toDouble()).reduce((a, b) => a < b ? a : b),
                maxY: pointsHistory.map((e) => (e['points'] as num).toDouble()).reduce((a, b) => a > b ? a : b),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(pointsHistory.length, (index) {
                      final points = (pointsHistory[index]['points'] as num).toDouble();
                      return FlSpot(index.toDouble(), points);
                    }),
                    isCurved: true,
                    color: AppColors.primaryBlue,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              Image.asset(AppColors.logoAsset, height: kToolbarHeight * 0.5),
              SizedBox(width: kToolbarHeight * 0.15),
              Text(
                t.myBets,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: kToolbarHeight * 0.38,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final appState = context.read<AppState>();
          await _loadBets();
          await _loadPointsHistory();
          if (mounted) {
            await appState.refreshUserData();
          }
        },
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Balance card
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDark, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  child: isLoadingUser
                      ? Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                      : Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.tagBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.account_balance_wallet_outlined, color: AppColors.primaryBlue, size: 32),
                            ),
                            const SizedBox(height: 12),
                            Text(t.yourBalance, style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 14))),
                            const SizedBox(height: 6),
                            Text(
                              "${appState.userData?['points'] ?? 0}",
                              style: TextStyle(color: AppColors.primaryBlue, fontSize: 42, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              "POINTS",
                              style: TextStyle(color: AppColors.textTertiary, fontSize: logScale(context, 12), fontWeight: FontWeight.w500, letterSpacing: 1),
                            ),
                          ],
                        ),
                ),
              ),

              _buildPointsGraph(),

              // Bets list
              isLoadingBets
                  ? Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
                    )
                  : bets.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sports_basketball_outlined, size: 64, color: AppColors.textTertiary),
                              const SizedBox(height: 16),
                              Text(t.noBetsSelected, style: TextStyle(fontSize: logScale(context, 16), color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: bets.length,
                          itemBuilder: (context, index) {
                            final bet = bets[index];
                            final amount = parseDouble(bet['points_betted']);
                            final odd = parseDouble(bet['odd']);
                            final payout = (amount * odd).toStringAsFixed(2);
                            final startTime = DateTime.tryParse(bet['timestamp'] ?? '') ?? context.read<Clock>().now();

                            final status = bet['status'] ?? 'pending';
                            Color statusColor;
                            Color statusBgColor;
                            IconData statusIcon;

                            switch (status) {
                              case 'won':
                                statusColor = AppColors.success;
                                statusBgColor = AppColors.tagGreen;
                                statusIcon = Icons.check_circle_outlined;
                                break;
                              case 'lost':
                                statusColor = AppColors.error;
                                statusBgColor = AppColors.tagRed;
                                statusIcon = Icons.cancel_outlined;
                                break;
                              default:
                                statusColor = AppColors.warning;
                                statusBgColor = AppColors.tagOrange;
                                statusIcon = Icons.schedule_outlined;
                            }

                            final List<dynamic> selections = (bet['selection'] ?? []) as List<dynamic>;

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderDark, width: 1),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
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
                                          decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(8)),
                                          child: Icon(statusIcon, color: statusColor, size: 22),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                selections.length > 1 ? t.multipleBets : (bet['pickedTeam'] ?? t.singleBet),
                                                style: TextStyle(color: AppColors.textPrimary, fontSize: logScale(context, 16), fontWeight: FontWeight.w600),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat.yMd(Localizations.localeOf(context).toString()).add_jm().format(startTime),
                                                style: TextStyle(color: AppColors.textTertiary, fontSize: logScale(context, 12)),
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
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(color: AppColors.tagBlue, borderRadius: BorderRadius.circular(6)),
                                            child: Text(team.toString(), style: TextStyle(color: AppColors.tagTextBlue, fontSize: logScale(context, 13), fontWeight: FontWeight.w500)),
                                          );
                                        }).toList(),
                                      ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: AppColors.surfaceHover, borderRadius: BorderRadius.circular(8)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildStatItem(t.odd, appState.convertOdds(odd), AppColors.primaryBlue),
                                          _divider(),
                                          _buildStatItem(t.amount, amount.toStringAsFixed(0), AppColors.warning),
                                          _divider(),
                                          _buildStatItem(t.payoutText, payout, AppColors.success),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(height: 36, width: 1, color: AppColors.borderDark);

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppColors.textTertiary, fontSize: logScale(context, 11))),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: logScale(context, 15))),
      ],
    );
  }
}
