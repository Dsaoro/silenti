import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/application/budgets/get_budget_summary_use_case.dart';
import 'package:silenti/application/budgets/get_expenses_categories_use_case.dart';
import 'package:silenti/application/budgets/get_income_categories_use_case.dart';
import 'package:silenti/infraestructure/storage/budget_categories_dao.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late GetBudgetSummaryUseCase useCase;

  setUp(() async {
    db = await openTestDatabase();
    final dao = BudgetCategoriesDAO(databaseProvider: () async => db);
    useCase = GetBudgetSummaryUseCase(
      incomeUseCase: GetIncomeCategoriesUseCase(dao: dao),
      expenseUseCase: GetExpensesCategoriesUseCase(dao: dao),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> seedCategory(String type, double amount, {int? parentId}) {
    return db.insert('budget_categories', {
      'parentId': parentId,
      'type': type,
      'name': 'Categoria',
      'amount': amount,
      'frequency': 'monthly',
      'firstTime': DateTime(2026, 1, 1).toIso8601String(),
    });
  }

  test('sums income and expense totals, including subcategories, without double counting',
      () async {
    final rentId = await seedCategory('spent', 500000);
    await seedCategory('spent', 50000, parentId: rentId); // subcategory
    await seedCategory('income', 2000000);
    await seedCategory('income', 300000);

    final result = await useCase.execute();

    expect(result.status, isTrue);
    expect(result.model!.totalExpense, 550000); // 500000 + 50000, not x2
    expect(result.model!.totalIncome, 2300000);
  });

  test('deficit is negative when expense exceeds income', () async {
    await seedCategory('spent', 3000000);
    await seedCategory('income', 2000000);

    final result = await useCase.execute();

    expect(result.model!.deficit, -1000000);
  });

  test('deficit is positive (surplus) when income exceeds expense', () async {
    await seedCategory('spent', 1000000);
    await seedCategory('income', 2000000);

    final result = await useCase.execute();

    expect(result.model!.deficit, 1000000);
  });

  test('an empty budget is a success with zero totals, not an error', () async {
    final result = await useCase.execute();

    expect(result.status, isTrue);
    expect(result.model!.totalIncome, 0);
    expect(result.model!.totalExpense, 0);
  });
}
