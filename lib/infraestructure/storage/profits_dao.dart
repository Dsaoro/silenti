import 'package:silenti/infraestructure/adapters/secure_database_helper.dart';

class ProfitsDAO {
  Future<int> insertProfit(Map<String, dynamic> data) async {
    final db = await SecureDatabaseHelper().database;
    return await db.insert('profits', data);
  }

  Future<List<Map<String, dynamic>>> getprofits(int accountId) async {
    final db = await SecureDatabaseHelper().database;
    return await db.query(
      'profits',
      where: 'account_id = ?',
      whereArgs: [accountId],
    );
  }
}
