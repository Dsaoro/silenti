import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class OperationDAO {
  Future<int> insertOperation(Map<String, dynamic> Operation) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.insert('Operations', Operation);
  }

  Future<List<Map<String, dynamic>>> getOperations() async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query('Operations', orderBy: 'fecha DESC');
  }

  Future<int> deleteOperation(int id) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.delete('Operations', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getOperationsByAssetId(int assetId) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query('Operations',
        where: 'account_id = ?', whereArgs: [assetId], orderBy: 'fecha DESC');
  }

  Future<List<Map<String, dynamic>>> getOperationsByAssetIdLimited(int assetId,
      {int? limit = 10}) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query('Operations',
        where: 'account_id = ?',
        limit: limit,
        whereArgs: [assetId],
        orderBy: 'fecha DESC');
  }
}
