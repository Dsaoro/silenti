import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class SpendSubCategoriesDao {
  final Future<Database> Function() _databaseProvider;
  SpendSubCategoriesDao({Future<Database> Function()? databaseProvider})
      : _databaseProvider =
            databaseProvider ?? (() => SecureDatabaseHelperPC().database);

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _databaseProvider();
    return await db.query(
      'spend_sub_categories',
    );
  }

  Future<List<Map<String, dynamic>>> getByCategoryId({required int id}) async {
    final db = await _databaseProvider();
    return await db.query(
      'spend_sub_categories',
      where: 'category = ?',
      whereArgs: [id],
    );
  }
}
