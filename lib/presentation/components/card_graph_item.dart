import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                color: Theme.of(context).colorScheme.onSurface,
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
            color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
            fontSize: 14,
          ),
        ),
      );
    }

    double minX = chartData.isNotEmpty ? chartData.first.x : 0;
    double maxX = chartData.isNotEmpty ? chartData.last.x : 1;

    // Handle edge case where there is only one point
    if (minX == maxX && chartData.isNotEmpty) {
      minX -= const Duration(days: 1).inMilliseconds.toDouble();
      maxX += const Duration(days: 1).inMilliseconds.toDouble();
    }

    double range = maxX - minX;

    double interval;
    if (range <= const Duration(days: 2).inMilliseconds) {
      interval = const Duration(hours: 4).inMilliseconds.toDouble();
    } else if (range <= const Duration(days: 7).inMilliseconds) {
      interval = const Duration(days: 1).inMilliseconds.toDouble();
    } else if (range <= const Duration(days: 31).inMilliseconds) {
      interval = const Duration(days: 5).inMilliseconds.toDouble();
    } else {
      interval = const Duration(days: 30).inMilliseconds.toDouble();
    }

    // Ensure interval is not zero
    if (interval == 0) interval = 1;

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          show: showTitles,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: interval,
              getTitlesWidget: (value, meta) {
                DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                String formattedDate;

                if (range <= const Duration(days: 2).inMilliseconds) {
                  // If range is within 2 days, show only time
                  formattedDate = DateFormat('HH:mm').format(date);
                } else if (range <= const Duration(days: 7).inMilliseconds) {
                  // If range is within 7 days, show abbreviated day and time
                  formattedDate = DateFormat('E HH:mm').format(date);
                } else {
                  // If scale is monthly (or larger), only consider the day
                  formattedDate = DateFormat('dd/MM').format(date);
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
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
              color: Theme.of(context).colorScheme.primary.withAlpha(25),
            ),
          ),
        ],
        minX: minX,
        maxX: maxX,
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
