import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hoopsleague/services/cache_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/utils.dart';

class PointsGraphPage extends StatefulWidget {
  final String uid;

  const PointsGraphPage({super.key, required this.uid});

  @override
  State<PointsGraphPage> createState() => _PointsGraphPageState();
}

enum GraphScope { week, month, sixMonths, year, all }

class _PointsGraphPageState extends State<PointsGraphPage> {
  List<Map<String, dynamic>> pointsHistory = [];
  List<Map<String, dynamic>> fullHistory = [];
  bool isLoading = true;
  GraphScope _selectedScope = GraphScope.month;

  @override
  void initState() {
    super.initState();
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
        onTimeout: () {
          return [];
        },
      );

      if (mounted) {
        setState(() {
          fullHistory = history;
          pointsHistory = _filterHistoryByScope(history, _selectedScope);
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          fullHistory = [];
          pointsHistory = [];
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

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
                t.myGraph,
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
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDark, width: 1),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        t.pointsEvolution,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: logScale(context, 20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Scope selector
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
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primaryBlue : AppColors.surfaceHover,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryBlue : AppColors.borderDark,
                                    ),
                                  ),
                                  child: Text(
                                    _getScopeLabel(scope),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.textSecondary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: logScale(context, 13),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: pointsHistory.isEmpty
                            ? Center(
                                child: Text(
                                  t.noData,
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: logScale(context, 16)),
                                ),
                              )
                            : LineChart(
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
                                            fontSize: logScale(context, 10),
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
                                              fontSize: logScale(context, 10),
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
                                  minY: pointsHistory
                                      .map((e) => (e['points'] as num).toDouble())
                                      .reduce((a, b) => a < b ? a : b),
                                  maxY: pointsHistory
                                      .map((e) => (e['points'] as num).toDouble())
                                      .reduce((a, b) => a > b ? a : b),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: List.generate(pointsHistory.length, (index) {
                                        final points = (pointsHistory[index]['points'] as num).toDouble();
                                        return FlSpot(index.toDouble(), points);
                                      }),
                                      isCurved: true,
                                      gradient: LinearGradient(
                                        colors: [AppColors.primaryBlue.withValues(alpha: 0.6), AppColors.primaryBlue],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      barWidth: 3,
                                      dotData: FlDotData(show: false),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primaryBlue.withValues(alpha: 0.15),
                                            Colors.transparent
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
