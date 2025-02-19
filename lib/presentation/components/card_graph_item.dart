import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:silenti/core/enums/silenti_styles.dart';

import '../../core/enums/silenti_colors.dart';

class CardGraphItem extends StatelessWidget {
  const CardGraphItem({super.key, required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildGraph(), const SizedBox(height: 16), _buildTitle()],
      ),
    );
  }

  Widget _buildGraph() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 2,
          ),
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
              lineBarsData: [
                LineChartBarData(
                  preventCurveOverShooting: true,
                  spots: [
                    FlSpot(0, 1),
                    FlSpot(1, 3),
                    FlSpot(2, 2),
                    FlSpot(3, 4),
                    FlSpot(4, 3.5),
                  ],
                  isCurved: true,
                  // colors: [Colors.blueAccent],
                  color: SilentiColors.secondary,
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    if (isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      );
    } else {
      return Padding(
        padding: EdgeInsets.fromLTRB(8, 2, 8, 4),
        child: Text(
          'Graph Title',
          style: SilentiStyles.titleTextStyle,
        ),
      );
    }
  }
}
