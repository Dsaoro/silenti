import 'package:flutter_test/flutter_test.dart';
import 'package:silenti/core/models/budget_category.dart';

BudgetCategory _category({
  required int id,
  int? parentId,
  double amount = 0,
  List<BudgetCategory> subcategories = const [],
}) {
  return BudgetCategory(
    id: id,
    parentId: parentId,
    type: CategoryType.spent,
    name: 'Categoria $id',
    amount: amount,
    frequency: 'monthly',
    firstTime: DateTime(2026, 1, 1),
    subcategories: subcategories,
  );
}

void main() {
  group('BudgetCategory.totalAmount', () {
    test('with no subcategories is just its own amount', () {
      final category = _category(id: 1, amount: 200000);

      expect(category.totalAmount, 200000);
    });

    test('sums its own amount plus every subcategory (2 levels)', () {
      final category = _category(
        id: 1,
        amount: 100000,
        subcategories: [
          _category(id: 2, parentId: 1, amount: 30000),
          _category(id: 3, parentId: 1, amount: 20000),
        ],
      );

      expect(category.totalAmount, 150000);
    });

    test('the getter itself recurses through any depth if the tree is built that deep', () {
      // BudgetCategory.totalAmount is recursive by design; whether the app
      // actually ever constructs a 3-level tree is a separate concern
      // (BUSINESS_LOGIC_AUDIT.md #3.8 / PRD.md H1.2 limit it to 2 levels at
      // the use-case layer, not here).
      final grandchild = _category(id: 3, parentId: 2, amount: 5000);
      final child = _category(
        id: 2,
        parentId: 1,
        amount: 10000,
        subcategories: [grandchild],
      );
      final root = _category(id: 1, amount: 1000, subcategories: [child]);

      expect(root.totalAmount, 16000);
    });
  });

  group('BudgetCategory.copyWith', () {
    test('overrides only the fields passed in', () {
      final original = _category(id: 1, amount: 100);

      final updated = original.copyWith(amount: 500);

      expect(updated.id, original.id);
      expect(updated.name, original.name);
      expect(updated.amount, 500);
    });
  });

  group('BudgetCategory.fromMap', () {
    test('always starts with empty subcategories (loaded separately)', () {
      final category = BudgetCategory.fromMap({
        'id': 1,
        'parentId': null,
        'type': CategoryType.income,
        'name': 'Salario',
        'amount': 3000000.0,
        'frequency': 'semi-monthly',
        'firstTime': '2026-01-01T00:00:00.000',
      });

      expect(category.subcategories, isEmpty);
      expect(category.type, CategoryType.income);
    });
  });
}
