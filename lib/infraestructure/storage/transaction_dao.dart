import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class TransactionDAO {
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.insert('transactions', transaction);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query('transactions', orderBy: 'fecha DESC');
  }

  Future<int> deleteTransaction(int id) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
