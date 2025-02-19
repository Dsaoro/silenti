import 'package:silenti/infraestructure/adapters/secure_database_helper.dart';

class AccountsDAO {
  Future<int> insertAccount(Map<String, dynamic> data) async {
    final db = await SecureDatabaseHelper().database;
    return await db.insert('accounts', data);
  }

  Future<List<Map<String, dynamic>>> getAccounts() async {
    final db = await SecureDatabaseHelper().database;
    return await db.query('accounts');
  }

  Future<List<Map<String, dynamic>>> getAccountById(int accountId) async {
    final db = await SecureDatabaseHelper().database;
    return await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }
}
