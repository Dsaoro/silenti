import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/application/budgets/delete_budget_category_use_case.dart';
import 'package:silenti/core/models/budget_category.dart';
import 'package:silenti/infraestructure/storage/budget_categories_dao.dart';
import 'package:silenti/infraestructure/storage/operation_dao.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late DeleteBudgetCategoryUseCase useCase;

  setUp(() async {
    db = await openTestDatabase();
    useCase = DeleteBudgetCategoryUseCase(
      dao: BudgetCategoriesDAO(databaseProvider: () async => db),
      operationDao: OperationDAO(databaseProvider: () async => db),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> seedCategory({int? parentId, String type = 'spent'}) {
    return db.insert('budget_categories', {
      'parentId': parentId,
      'type': type,
      'name': 'Categoria',
      'amount': 1000.0,
      'frequency': 'monthly',
      'firstTime': DateTime(2026, 1, 1).toIso8601String(),
    });
  }

  BudgetCategory categoryOf(int id) => BudgetCategory(
        id: id,
        type: 'spent',
        name: 'Categoria',
        amount: 1000,
        frequency: 'monthly',
        firstTime: DateTime(2026, 1, 1),
      );

  test('deletes a category with no subcategories and no operations', () async {
    final id = await seedCategory();

    final result = await useCase.execute(categoryOf(id));

    expect(result.status, isTrue);
    expect(await db.query('budget_categories'), isEmpty);
  });

  test('refuses to delete a category that still has subcategories', () async {
    final parentId = await seedCategory();
    await seedCategory(parentId: parentId);

    final result = await useCase.execute(categoryOf(parentId));

    expect(result.status, isFalse);
    expect(await db.query('budget_categories'), hasLength(2));
  });

  test('refuses to delete a category with transactions associated with it', () async {
    final id = await seedCategory();
    await db.insert('Operations', {
      'financialAsset': 1,
      'amount': 100.0,
      'date': DateTime(2026, 1, 5).toIso8601String(),
      'description': 'Compra',
      'category': id,
      'type': 'spent',
    });

    final result = await useCase.execute(categoryOf(id));

    expect(result.status, isFalse);
    expect(await db.query('budget_categories'), hasLength(1));
  });
}
