import 'package:fl_chart/fl_chart.dart';
import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class GetTotalBalanceChartDataUseCase extends BaseUseCase {
  GetTotalBalanceChartDataUseCase() : super("GetTotalBalanceChartData");

  Future<HandleResult<List<FlSpot>>> execute({
    DateTime? fromDate,
    DateTime? toDate,
    int maxPoints = 50,
  }) async {
    HandleResult<List<FlSpot>> result = HandleResult<List<FlSpot>>();

    try {
      // Obtener el historial de balances de todos los activos
      final db = await SecureDatabaseHelperPC().database;

      String whereClause = "1=1"; // Siempre verdadero
      List<dynamic> whereArgs = [];

      if (fromDate != null) {
        whereClause += ' AND date >= ?';
        whereArgs.add(fromDate.toIso8601String());
      }

      if (toDate != null) {
        whereClause += ' AND date <= ?';
        whereArgs.add(toDate.toIso8601String());
      }

      // Query simplificado para obtener el balance total por fecha
      final String query = '''
        SELECT 
          date,
          SUM(balance) as total_balance
        FROM balance_history 
        WHERE $whereClause
        GROUP BY date
        ORDER BY date ASC
        LIMIT ?
      ''';

      List<dynamic> finalArgs = [...whereArgs, maxPoints];
      final List<Map<String, dynamic>> chartData =
          await db.rawQuery(query, finalArgs);

      if (chartData.isEmpty) {
        result.setData([]);
        return result;
      }

      // Convertir a FlSpot para fl_chart
      List<FlSpot> spots = [];
      DateTime? firstDate;

      for (int i = 0; i < chartData.length; i++) {
        DateTime currentDate = DateTime.parse(chartData[i]['date']);
        double totalBalance = chartData[i]['total_balance']?.toDouble() ?? 0.0;

        // Usar el primer punto como referencia temporal
        if (firstDate == null) {
          firstDate = currentDate;
          spots.add(FlSpot(0, totalBalance));
        } else {
          // Calcular días desde el primer punto
          double daysDifference =
              currentDate.difference(firstDate).inDays.toDouble();
          spots.add(FlSpot(daysDifference, totalBalance));
        }
      }

      result.setData(spots);
    } catch (e) {
      result
          .setError("Error loading total balance chart data: ${e.toString()}");
    }

    return result;
  }

  // Método simplificado para la página principal
  Future<HandleResult<List<FlSpot>>> executeForHome() async {
    DateTime now = DateTime.now();
    DateTime fromDate =
        DateTime(now.year, now.month - 1, now.day); // Último mes

    return execute(
      fromDate: fromDate,
      toDate: now,
      maxPoints: 30,
    );
  }
}
