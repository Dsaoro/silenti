import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class IngresoDAO {
  Future<int> insertBudgetCategory(Map<String, dynamic> ingreso) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.insert('budgetCategories', ingreso);
  }

  Future<List<Map<String, dynamic>>> getBudgetCategories() async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query('budgetCategories', orderBy: 'fecha_inicio DESC');
  }

  Future<List<Map<String, dynamic>>> getBudgetExpenses() async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query('budgetCategories',
        orderBy: 'fecha_inicio DESC'); // TODO filter spent
  }

  Future<List<Map<String, dynamic>>> getBudgetIncomes() async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query('budgetCategories',
        orderBy: 'fecha_inicio DESC'); // TODO filter income
  }
}
