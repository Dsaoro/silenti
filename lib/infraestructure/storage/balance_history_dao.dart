import 'package:silenti/core/models/balance_history.dart';
import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class BalanceHistoryDAO {
  Future<int> insertBalanceHistory(BalanceHistory balanceHistory) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.insert('balance_history', balanceHistory.toMap());
  }

  Future<List<BalanceHistory>> getBalanceHistoryByAsset(
    int financialAssetId, {
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final db = await SecureDatabaseHelperPC().database;

    String whereClause = 'financialAssetId = ?';
    List<dynamic> whereArgs = [financialAssetId];

    if (fromDate != null) {
      whereClause += ' AND date >= ?';
      whereArgs.add(fromDate.toIso8601String());
    }

    if (toDate != null) {
      whereClause += ' AND date <= ?';
      whereArgs.add(toDate.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'balance_history',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date ASC',
      limit: limit,
    );

    return maps.map((map) => BalanceHistory.fromMap(map)).toList();
  }

  Future<List<BalanceHistory>> getLatestBalanceForAllAssets() async {
    final db = await SecureDatabaseHelperPC().database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT bh1.* FROM balance_history bh1
      INNER JOIN (
        SELECT financialAssetId, MAX(date) as max_date
        FROM balance_history
        GROUP BY financialAssetId
      ) bh2 ON bh1.financialAssetId = bh2.financialAssetId 
      AND bh1.date = bh2.max_date
    ''');

    return maps.map((map) => BalanceHistory.fromMap(map)).toList();
  }

  Future<BalanceHistory?> getLatestBalanceForAsset(int financialAssetId) async {
    final db = await SecureDatabaseHelperPC().database;

    final List<Map<String, dynamic>> maps = await db.query(
      'balance_history',
      where: 'financialAssetId = ?',
      whereArgs: [financialAssetId],
      orderBy: 'date DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return BalanceHistory.fromMap(maps.first);
  }

  // Para obtener datos optimizados para gráficas
  Future<List<Map<String, dynamic>>> getChartDataForAsset(
    int financialAssetId, {
    DateTime? fromDate,
    DateTime? toDate,
    int maxPoints = 50,
  }) async {
    final db = await SecureDatabaseHelperPC().database;

    String whereClause = 'financialAssetId = ?';
    List<dynamic> whereArgs = [financialAssetId];

    if (fromDate != null) {
      whereClause += ' AND date >= ?';
      whereArgs.add(fromDate.toIso8601String());
    }

    if (toDate != null) {
      whereClause += ' AND date <= ?';
      whereArgs.add(toDate.toIso8601String());
    }

    // Si hay muchos puntos, tomamos una muestra representativa
    final String query = '''
      SELECT 
        date,
        balance,
        ROW_NUMBER() OVER (ORDER BY date) as row_num,
        COUNT(*) OVER () as total_count
      FROM balance_history 
      WHERE $whereClause
      ORDER BY date ASC
    ''';

    final List<Map<String, dynamic>> allData =
        await db.rawQuery(query, whereArgs);

    if (allData.length <= maxPoints) {
      return allData;
    }

    // Tomar una muestra distribuida uniformemente
    final int step = (allData.length / maxPoints).ceil();
    final List<Map<String, dynamic>> sampledData = [];

    for (int i = 0; i < allData.length; i += step) {
      sampledData.add(allData[i]);
    }

    // Asegurar que incluimos el último punto
    if (sampledData.last != allData.last) {
      sampledData.add(allData.last);
    }

    return sampledData;
  }
}
