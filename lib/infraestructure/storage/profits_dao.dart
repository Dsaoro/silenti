import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class ProfitsDAO {
  Future<int> insertProfit(Map<String, dynamic> data) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.insert('profits', data);
  }

  Future<List<Map<String, dynamic>>> getprofits(int financialAsset) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query(
      'profits',
      where: 'financialAsset = ?',
      whereArgs: [financialAsset],
    );
  }
}
