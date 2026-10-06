import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/application/budgets/get_budgeted_amount_for_month_use_case.dart';
import 'package:silenti/infraestructure/storage/budget_categories_dao.dart';
import 'package:silenti/infraestructure/storage/budget_category_snapshot_dao.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late GetBudgetedAmountForMonthUseCase useCase;
  late BudgetCategoriesDAO categoriesDao;

  setUp(() async {
    db = await openTestDatabase();
    categoriesDao = BudgetCategoriesDAO(databaseProvider: () async => db);
    useCase = GetBudgetedAmountForMonthUseCase(
      categoriesDao: categoriesDao,
      snapshotDao: BudgetCategorySnapshotDao(databaseProvider: () async => db),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> seedCategory(double amount) {
    return db.insert('budget_categories', {
      'parentId': null,
      'type': 'spent',
      'name': 'Categoria',
      'amount': amount,
      'frequency': 'monthly',
      'firstTime': DateTime(2026, 1, 1).toIso8601String(),
    });
  }

  test('reads the live amount for the current month', () async {
    final id = await seedCategory(1000);

    final result = await useCase.execute(
        categoryId: id, year: 2026, month: 3, now: DateTime(2026, 3, 15));

    expect(result.status, isTrue);
    expect(result.model, 1000);
  });

  test('reads the live amount for a future month', () async {
    final id = await seedCategory(1000);

    final result = await useCase.execute(
        categoryId: id, year: 2026, month: 6, now: DateTime(2026, 3, 15));

    expect(result.model, 1000);
  });

  test('a past month with a recorded snapshot ignores later live edits', () async {
    final id = await seedCategory(500);
    await db.insert('budget_category_snapshot', {
      'categoryId': id,
      'year': 2026,
      'month': 2,
      'amount': 500.0,
    });

    // The user raises the budget after February closed.
    await db.update('budget_categories', {'amount': 9000.0},
        where: 'id = ?', whereArgs: [id]);

    final result = await useCase.execute(
        categoryId: id, year: 2026, month: 2, now: DateTime(2026, 3, 15));

    expect(result.model, 500); // February's recorded value, not the new 9000
  });

  test('a past month with no recorded snapshot is 0.0, not an error', () async {
    final id = await seedCategory(1000);

    final result = await useCase.execute(
        categoryId: id, year: 2025, month: 1, now: DateTime(2026, 3, 15));

    expect(result.status, isTrue);
    expect(result.model, 0.0);
  });
}
