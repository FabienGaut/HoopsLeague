import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:HoopsBets/services/cache_service.dart';

class PointsGraphPage extends StatefulWidget {
  const PointsGraphPage({super.key});

  @override
  State<PointsGraphPage> createState() => _PointsGraphPageState();
}

class _PointsGraphPageState extends State<PointsGraphPage> {
  List<Map<String, dynamic>> pointsHistory = []; // {date: DateTime, points: int}
  bool isLoading = true;

  // Couleurs du thème sombre
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color accentPrimary = Colors.deepPurple;
  static const Color accentGold = Color(0xFFFFD700);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _loadPointsHistory();

  }


  Future<void> _loadPointsHistory() async {
    // Récupère depuis le cache un historique de points
    final history = await CacheService.loadPointsHistory();
    setState(() {
      pointsHistory = history;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: const Text('Évolution des points', style:  TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pointsHistory.isEmpty
          ? Center(
        child: Text(
          "Aucune donnée disponible",
          style: TextStyle(color: textSecondary),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: cardBg,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 5,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                            color: textSecondary, fontSize: 12),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= pointsHistory.length) {
                          return const SizedBox.shrink();
                        }
                        final date = pointsHistory[index]['date'] as DateTime;
                        return Text(
                          "${date.day}/${date.month}",
                          style: TextStyle(
                              color: textSecondary, fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                minX: 0,
                maxX: (pointsHistory.length - 1).toDouble(),
                minY: pointsHistory
                    .map((e) => (e['points'] as int).toDouble())
                    .reduce((a, b) => a < b ? a : b),
                maxY: pointsHistory
                    .map((e) => (e['points'] as int).toDouble())
                    .reduce((a, b) => a > b ? a : b),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(pointsHistory.length, (index) {
                      final points = pointsHistory[index]['points'] as int;
                      return FlSpot(index.toDouble(), points.toDouble());
                    }),
                    isCurved: true,
                    color: accentGold,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
