import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class OperationDAO {
  final Future<Database> Function() _databaseProvider;
  OperationDAO({Future<Database> Function()? databaseProvider})
      : _databaseProvider =
            databaseProvider ?? (() => SecureDatabaseHelperPC().database);

  Future<int> insertOperation(Map<String, dynamic> operation) async {
    final db = await _databaseProvider();
    return await db.insert('Operations', operation);
  }

  Future<List<Map<String, dynamic>>> getOperations() async {
    final db = await _databaseProvider();
    return await db.query('Operations', orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getOperationsLimited(
      {required int limit}) async {
    final db = await _databaseProvider();
    return await db.query('Operations', orderBy: 'date DESC', limit: limit);
  }

  Future<int> deleteOperation(int id) async {
    final db = await _databaseProvider();
    return await db.delete('Operations', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getOperationsByAssetId(int assetId) async {
    final db = await _databaseProvider();
    return await db.query('Operations',
        where: 'financialAsset = ?',
        whereArgs: [assetId],
        orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getOperationsByAssetIdLimited(int assetId,
      {int? limit = 10}) async {
    final db = await _databaseProvider();
    return await db.query('Operations',
        where: 'financialAsset = ?',
        limit: limit,
        whereArgs: [assetId],
        orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getOperationsByBudgetCategoryLimited(
      int budgetId,
      {int? limit = 10}) async {
    final db = await _databaseProvider();
    return await db.query('Operations',
        where: 'category = ?',
        limit: limit,
        whereArgs: [budgetId],
        orderBy: 'date DESC');
  }

  Future<double> getSpentAmountByCategoryAndMonth(
      int categoryId, int month, int year) async {
    final db = await _databaseProvider();
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

  /// Total spent in [month]/[year]. Always returns exactly one row with an
  /// `amount` key (0 when there are no operations that month) —
  /// deliberately not `GROUP BY`, which returns zero rows for an empty
  /// month and used to make callers crash on `.first`
  /// (BUSINESS_LOGIC_AUDIT.md #3.6).
  Future<List<Map<String, Object?>>> getSpendByMonth(
      {required int month, required int year}) async {
    final db = await _databaseProvider();
    final monthStr = month.toString().padLeft(2, '0');
    List<Map<String, Object?>> result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) as amount
      FROM Operations
      WHERE strftime('%m', date) = ? AND strftime('%Y', date) = ?
      ''',
      [monthStr, year.toString()],
    );
    return result;
  }
}
