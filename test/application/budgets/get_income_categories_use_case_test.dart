import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/application/budgets/get_income_categories_use_case.dart';
import 'package:silenti/infraestructure/storage/budget_categories_dao.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late GetIncomeCategoriesUseCase useCase;

  setUp(() async {
    db = await openTestDatabase();
    useCase = GetIncomeCategoriesUseCase(
      dao: BudgetCategoriesDAO(databaseProvider: () async => db),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedCategory(String type, String name) {
    return db.insert('budget_categories', {
      'parentId': null,
      'type': type,
      'name': name,
      'amount': 1000.0,
      'frequency': 'monthly',
      'firstTime': DateTime(2026, 1, 1).toIso8601String(),
    });
  }

  test('returns only income-type categories, not expense ones', () async {
    // BUSINESS_LOGIC_AUDIT.md #3.5 — before this use case existed, income
    // operations were categorized against exactly this kind of 'spent' row.
    await seedCategory('income', 'Salario');
    await seedCategory('spent', 'Transporte');

    final result = await useCase.execute();

    expect(result.status, isTrue);
    expect(result.model!.map((c) => c.name), ['Salario']);
    expect(result.model!.every((c) => c.type == 'income'), isTrue);
  });

  test('an empty category list is still a success', () async {
    final result = await useCase.execute();

    expect(result.status, isTrue);
    expect(result.model, isEmpty);
  });
}
