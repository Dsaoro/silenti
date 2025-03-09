import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class FinancialAssetsDao {
  Future<int> insertAccount(Map<String, dynamic> data) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.insert('financial_assets', data);
  }

  Future<List<Map<String, dynamic>>> getAccounts() async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query('financial_assets');
  }

  Future<List<Map<String, dynamic>>> getAccountById(int financialAsset) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query(
      'financial_assets',
      where: 'id = ?',
      whereArgs: [financialAsset],
    );
  }

  Future<int> updateAccountById(
      int financialAsset, Map<String, dynamic> data) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.update(
      'financial_assets',
      data,
      where: 'id = ?',
      whereArgs: [financialAsset],
    );
  }
}
