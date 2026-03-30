import 'package:fl_chart/fl_chart.dart';
import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/infraestructure/storage/balance_history_dao.dart';

class GetAssetChartDataUseCase extends BaseUseCase {
  GetAssetChartDataUseCase() : super("GetAssetChartData");

  Future<HandleResult<List<FlSpot>>> execute({
    required int financialAssetId,
    DateTime? fromDate,
    DateTime? toDate,
    int maxPoints = 50,
  }) async {
    HandleResult<List<FlSpot>> result = HandleResult<List<FlSpot>>();

    try {
      BalanceHistoryDAO dao = BalanceHistoryDAO();

      // Obtener datos de la base de datos
      List<Map<String, dynamic>> chartData = await dao.getChartDataForAsset(
        financialAssetId,
        fromDate: fromDate,
        toDate: toDate,
        maxPoints: maxPoints,
      );

      if (chartData.isEmpty) {
        result.setData([]);
        return result;
      }

      // Convertir a FlSpot para fl_chart
      List<FlSpot> spots = [];

      for (int i = 0; i < chartData.length; i++) {
        DateTime currentDate = DateTime.parse(chartData[i]['date']);
        double balance = chartData[i]['balance']?.toDouble() ?? 0.0;

        spots.add(FlSpot(currentDate.millisecondsSinceEpoch.toDouble(), balance));
      }

      result.setData(spots);
    } catch (e) {
      result.setError("Error loading chart data: ${e.toString()}");
    }

    return result;
  }

  // Método alternativo para obtener datos por período específico
  Future<HandleResult<List<FlSpot>>> executeByPeriod({
    required int financialAssetId,
    required ChartPeriod period,
  }) async {
    DateTime now = DateTime.now();
    DateTime? fromDate;

    switch (period) {
      case ChartPeriod.week:
        fromDate = now.subtract(Duration(days: 7));
        break;
      case ChartPeriod.month:
        fromDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case ChartPeriod.threeMonths:
        fromDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case ChartPeriod.sixMonths:
        fromDate = DateTime(now.year, now.month - 6, now.day);
        break;
      case ChartPeriod.year:
        fromDate = DateTime(now.year - 1, now.month, now.day);
        break;
      case ChartPeriod.all:
        fromDate = null;
        break;
    }

    return execute(
      financialAssetId: financialAssetId,
      fromDate: fromDate,
      toDate: now,
    );
  }
}

enum ChartPeriod {
  week,
  month,
  threeMonths,
  sixMonths,
  year,
  all,
}
