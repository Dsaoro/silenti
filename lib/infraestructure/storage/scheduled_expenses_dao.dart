import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class ScheduledExpensesDao {
  final Future<Database> Function() _databaseProvider;
  ScheduledExpensesDao({Future<Database> Function()? databaseProvider})
      : _databaseProvider =
            databaseProvider ?? (() => SecureDatabaseHelperPC().database);

  Future<int> insert(Map<String, dynamic> data) async {
    final db = await _databaseProvider();
    return await db.insert('scheduled_expenses', data);
  }

  Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await _databaseProvider();
    return await db.update(
      'scheduled_expenses',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseProvider();
    return await db.delete(
      'scheduled_expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _databaseProvider();
    return await db.query('scheduled_expenses');
  }

  Future<List<Map<String, dynamic>>> getActive() async {
    final db = await _databaseProvider();
    return await db.query(
      'scheduled_expenses',
      where: 'active = ?',
      whereArgs: [1],
    );
  }
}
