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

  Future<List<Map<String, Object?>>> getSpendByMonth(
      {required int month, required int year}) async {
    final db = await SecureDatabaseHelperPC().database;
    List<Map<String, Object?>> result = await db.rawQuery(
      '''SELECT SUM(amount) as amount FROM Operations GROUP BY STRFTIME('%m-%Y', date)''',
    );
    return result;
  }
}
