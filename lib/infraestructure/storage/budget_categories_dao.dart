import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class BudgetCategoriesDAO {
  Future<int> insertBudgetCategory(Map<String, dynamic> category) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.insert(
      'budget_categories',
      category,
    );
  }

  Future<int> updateBudgetCategory(Map<String, dynamic> category) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.update(
      'budget_categories',
      category,
      where: 'id = ?',
      whereArgs: [category['id']],
    );
  }

  Future<List<Map<String, dynamic>>> getBudgetCategories() async {
    final db = await SecureDatabaseHelperPC().database;
    // Using CTE to get hierarchy if needed, or just plain select if we handle tree building in Dart
    // For now, fetching all is sufficient, but we order by hierarchical path if possible or just standard
    // The recursive query helps if we want to sort by tree order, but requires building the path string
    return await db.query(
      'budget_categories',
      orderBy: 'id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getHierarchicalCategories() async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.rawQuery('''
      WITH RECURSIVE category_tree(id, parentId, type, name, amount, frequency, firstTime, level) AS (
        SELECT id, parentId, type, name, amount, frequency, firstTime, 0 
        FROM budget_categories WHERE parentId IS NULL
        UNION ALL
        SELECT c.id, c.parentId, c.type, c.name, c.amount, c.frequency, c.firstTime, ct.level + 1 
        FROM budget_categories c JOIN category_tree ct ON c.parentId = ct.id
      )
      SELECT * FROM category_tree ORDER BY type, name;
    ''');
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
