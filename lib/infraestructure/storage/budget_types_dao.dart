import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class IngresoDAO {
  Future<int> insertBudgetCategory(Map<String, dynamic> category) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.insert(
      'budget_categories',
      category,
    );
  }

  Future<List<Map<String, dynamic>>> getBudgetCategories() async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query(
      'budget_categories',
      orderBy: 'id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getBudgetExpenses() async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query(
      'budget_categories',
      where: 'type = ?',
      whereArgs: ['spent'],
      orderBy: 'id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getBudgetIncomes() async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query(
      'budget_categories',
      where: 'type = ?',
      whereArgs: ['income'],
      orderBy: 'id DESC',
    );
  }
}
