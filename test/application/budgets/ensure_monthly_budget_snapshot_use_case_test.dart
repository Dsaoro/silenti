import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/application/budgets/ensure_monthly_budget_snapshot_use_case.dart';
import 'package:silenti/infraestructure/storage/budget_categories_dao.dart';
import 'package:silenti/infraestructure/storage/budget_category_snapshot_dao.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late EnsureMonthlyBudgetSnapshotUseCase useCase;
  late BudgetCategorySnapshotDao snapshotDao;

  setUp(() async {
    db = await openTestDatabase();
    final categoriesDao = BudgetCategoriesDAO(databaseProvider: () async => db);
    snapshotDao = BudgetCategorySnapshotDao(databaseProvider: () async => db);
    useCase = EnsureMonthlyBudgetSnapshotUseCase(
      categoriesDao: categoriesDao,
      snapshotDao: snapshotDao,
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

  test('creates a snapshot of last month using the category\'s current amount',
      () async {
    final id = await seedCategory(500000);

    final result =
        await useCase.execute(now: DateTime(2026, 3, 15)); // last month = Feb

    expect(result.status, isTrue);
    expect(result.model, 1); // one snapshot created

    final snapshot = await snapshotDao.getSnapshot(id, 2026, 2);
    expect(snapshot!['amount'], 500000.0);
  });

  test('running it again does not overwrite an already-recorded past snapshot',
      () async {
    final id = await seedCategory(500000);
    await useCase.execute(now: DateTime(2026, 3, 15));

    // The user edits the category's live amount mid-way through March...
    await db.update('budget_categories', {'amount': 999999.0},
        where: 'id = ?', whereArgs: [id]);

    // ...and the use case runs again later in March, still targeting Feb.
    final secondRun = await useCase.execute(now: DateTime(2026, 3, 28));

    expect(secondRun.model, 0); // nothing new created, Feb already exists
    final febSnapshot = await snapshotDao.getSnapshot(id, 2026, 2);
    expect(febSnapshot!['amount'], 500000.0); // unchanged
  });

  test('handles the January → December-of-previous-year rollover', () async {
    await seedCategory(100.0);

    final result = await useCase.execute(now: DateTime(2026, 1, 10));

    expect(result.status, isTrue);
    final snapshots = await snapshotDao.getSnapshotsForMonth(2025, 12);
    expect(snapshots, hasLength(1));
  });
}
