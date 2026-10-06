import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class BudgetCategorySnapshotDao {
  final Future<Database> Function() _databaseProvider;
  BudgetCategorySnapshotDao({Future<Database> Function()? databaseProvider})
      : _databaseProvider =
            databaseProvider ?? (() => SecureDatabaseHelperPC().database);

  Future<Map<String, dynamic>?> getSnapshot(
      int categoryId, int year, int month) async {
    final db = await _databaseProvider();
    final rows = await db.query(
      'budget_category_snapshot',
      where: 'categoryId = ? AND year = ? AND month = ?',
      whereArgs: [categoryId, year, month],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> getSnapshotsForMonth(
      int year, int month) async {
    final db = await _databaseProvider();
    return await db.query(
      'budget_category_snapshot',
      where: 'year = ? AND month = ?',
      whereArgs: [year, month],
    );
  }

  /// Inserts a snapshot for (categoryId, year, month) only if one doesn't
  /// already exist — a past month's recorded amount must never change once
  /// written. Returns true if a row was inserted.
  Future<bool> insertIfMissing({
    required int categoryId,
    required int year,
    required int month,
    required double amount,
  }) async {
    final existing = await getSnapshot(categoryId, year, month);
    if (existing != null) return false;

    final db = await _databaseProvider();
    await db.insert('budget_category_snapshot', {
      'categoryId': categoryId,
      'year': year,
      'month': month,
      'amount': amount,
    });
    return true;
  }
}
