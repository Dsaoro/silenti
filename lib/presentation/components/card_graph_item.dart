import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
// import 'package:silenti/core/enums/silenti_styles.dart';

class CardGraphItem extends StatelessWidget {
  const CardGraphItem({
    super.key,
    required this.isLoading,
    this.title = "",
    this.chartData = const [],
    this.showGrid = false,
    this.showTitles = true,
  });

  final bool isLoading;
  final String title;
  final List<FlSpot> chartData;
  final bool showGrid;
  final bool showTitles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGraph(context),
          if (title.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGraph(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          child: _buildChart(context),
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (chartData.isEmpty) {
      return Center(
        child: Text(
          'No hay datos disponibles',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      );
    }

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: showTitles),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: showGrid),
        lineBarsData: [
          LineChartBarData(
            preventCurveOverShooting: true,
            spots: chartData,
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
        minX: chartData.isNotEmpty ? chartData.first.x : 0,
        maxX: chartData.isNotEmpty ? chartData.last.x : 1,
        minY: _getMinY(),
        maxY: _getMaxY(),
      ),
    );
  }

  double _getMinY() {
    if (chartData.isEmpty) return 0;
    double minY =
        chartData.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    return minY * 0.95; // 5% de margen inferior
  }

  double _getMaxY() {
    if (chartData.isEmpty) return 1;
    double maxY =
        chartData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return maxY * 1.05; // 5% de margen superior
  }
}
