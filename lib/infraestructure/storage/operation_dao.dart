import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class OperationDAO {
  Future<int> insertOperation(Map<String, dynamic> operation) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.insert('Operations', operation);
  }

  Future<List<Map<String, dynamic>>> getOperations() async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query('Operations', orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getOperationsLimited(
      {required int limit}) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query('Operations', orderBy: 'date DESC', limit: limit);
  }

  Future<int> deleteOperation(int id) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.delete('Operations', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getOperationsByAssetId(int assetId) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query('Operations',
        where: 'financialAsset = ?',
        whereArgs: [assetId],
        orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getOperationsByAssetIdLimited(int assetId,
      {int? limit = 10}) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query('Operations',
        where: 'financialAsset = ?',
        limit: limit,
        whereArgs: [assetId],
        orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getOperationsByBudgetCategoryLimited(
      int budgetId,
      {int? limit = 10}) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query('Operations',
        where: 'category = ?',
        limit: limit,
        whereArgs: [budgetId],
        orderBy: 'date DESC');
  }

  Future<double> getSpentAmountByCategoryAndMonth(
      int categoryId, int month, int year) async {
    final db = await SecureDatabaseHelperPC().database;
    final monthStr = month.toString().padLeft(2, '0');
    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total 
      FROM operations 
      WHERE category = ? 
      AND type = 'spent'
      AND strftime('%m', date) = ? 
      AND strftime('%Y', date) = ?
      ''',
      [categoryId, monthStr, year.toString()],
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  Future<List<Map<String, Object?>>> getSpendByMonth(
      {required int month, required int year}) async {
    final db = await SecureDatabaseHelperPC().database;
    final monthStr = month.toString().padLeft(2, '0');
    List<Map<String, Object?>> result = await db.rawQuery(
      '''
      SELECT SUM(amount) as amount 
      FROM Operations 
      WHERE strftime('%m', date) = ? AND strftime('%Y', date) = ?
      GROUP BY strftime('%m-%Y', date)
      ''',
      [monthStr, year.toString()],
    );
    return result;
  }
}
