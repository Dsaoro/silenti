import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/application/budgets/get_expenses_categories_use_case.dart';
import 'package:silenti/infraestructure/storage/budget_categories_dao.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late GetExpensesCategoriesUseCase useCase;

  setUp(() async {
    db = await openTestDatabase();
    useCase = GetExpensesCategoriesUseCase(
      dao: BudgetCategoriesDAO(databaseProvider: () async => db),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> seedCategory({int? parentId, String name = 'Categoria'}) {
    return db.insert('budget_categories', {
      'parentId': parentId,
      'type': 'spent',
      'name': name,
      'amount': 1000.0,
      'frequency': 'monthly',
      'firstTime': DateTime(2026, 1, 1).toIso8601String(),
    });
  }

  test('builds a 2-level tree and drops a seeded 3rd level', () async {
    // PRD.md H1.2 / BUSINESS_LOGIC_AUDIT.md #3.8 — 2 levels is the
    // documented limit now, not an accidental truncation.
    final rootId = await seedCategory(name: 'Transporte');
    final childId = await seedCategory(parentId: rootId, name: 'Combustible');
    await seedCategory(parentId: childId, name: 'Nieto (no debe aparecer)');

    final result = await useCase.execute();

    expect(result.status, isTrue);
    expect(result.model, hasLength(1));
    final root = result.model!.first;
    expect(root.subcategories, hasLength(1));
    expect(root.subcategories.first.name, 'Combustible');
    expect(root.subcategories.first.subcategories, isEmpty);
  });

  test('an empty category list is a success, not an error', () async {
    final result = await useCase.execute();

    expect(result.status, isTrue);
    expect(result.model, isEmpty);
  });
}
