import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class SpendSubCategoriesDao {
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query(
      'spend_sub_categories',
    );
  }

  Future<List<Map<String, dynamic>>> getByCategoryId({required int id}) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query(
      'spend_sub_categories',
      where: 'category = ?',
      whereArgs: [id],
    );
  }
}
