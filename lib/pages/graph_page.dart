import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hoopsleague/services/cache_service.dart';
import '../l10n/app_localizations.dart';

class PointsGraphPage extends StatefulWidget {
  const PointsGraphPage({super.key});

  @override
  State<PointsGraphPage> createState() => _PointsGraphPageState();
}

class _PointsGraphPageState extends State<PointsGraphPage> {
  List<Map<String, dynamic>> pointsHistory = [];
  bool isLoading = true;

  // 🎨 Palette harmonisée (même que Leaderboard)
  static const Color accentPrimary = Color(0xFF256af4);
  static const Color accentGlow = Color(0xFF9C9CFF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;

  @override
  void initState() {
    super.initState();
    _loadPointsHistory();
  }

  Future<void> _loadPointsHistory() async {
    final history = await CacheService.loadPointsHistory();
    setState(() {
      pointsHistory = history;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 28),
            const SizedBox(width: 8),
            Text(
              "HoopsLeague",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 🌌 Dégradé bleu → noir
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF314368), Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: accentPrimary))
                : pointsHistory.isEmpty
                ? Center(
              child: Text(
                t.noData,
                style: const TextStyle(color: textSecondary, fontSize: 16),
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  backgroundBlendMode: BlendMode.overlay,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      t.pointsEvolution,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 10,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.white.withOpacity(0.1),
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
                                  style: const TextStyle(
                                    color: textSecondary,
                                    fontSize: 10,
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
                                    style: const TextStyle(
                                      color: textSecondary,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
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
                                final points =
                                (pointsHistory[index]['points'] as num).toDouble();
                                return FlSpot(index.toDouble(), points);
                              }),
                              isCurved: true,
                              gradient: const LinearGradient(
                                colors: [accentGlow, accentPrimary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    accentGlow.withOpacity(0.25),
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
        ],
      ),
    );
  }
}
