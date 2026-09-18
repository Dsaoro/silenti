import 'package:flutter_test/flutter_test.dart';
import 'package:silenti/application/budgets/budget_category_tree.dart';

Map<String, dynamic> _row({
  required int id,
  int? parentId,
  String type = 'spent',
  double amount = 1000,
}) {
  return {
    'id': id,
    'parentId': parentId,
    'type': type,
    'name': 'Categoria $id',
    'amount': amount,
    'frequency': 'monthly',
    'firstTime': DateTime(2026, 1, 1).toIso8601String(),
  };
}

void main() {
  group('buildCategoryTree', () {
    test('attaches direct children to their root', () {
      final tree = buildCategoryTree([
        _row(id: 1),
        _row(id: 2, parentId: 1),
        _row(id: 3, parentId: 1),
      ]);

      expect(tree, hasLength(1));
      expect(tree.first.subcategories.map((c) => c.id), [2, 3]);
    });

    test('drops a would-be 3rd level (grandchildren) — PRD.md H1.2', () {
      final tree = buildCategoryTree([
        _row(id: 1), // root
        _row(id: 2, parentId: 1), // valid subcategory
        _row(id: 3, parentId: 2), // would be a grandchild — dropped
      ]);

      expect(tree, hasLength(1));
      expect(tree.first.subcategories, hasLength(1));
      expect(tree.first.subcategories.first.id, 2);
      expect(tree.first.subcategories.first.subcategories, isEmpty);
    });

    test('drops an orphan whose parentId matches no row', () {
      final tree = buildCategoryTree([
        _row(id: 1),
        _row(id: 2, parentId: 999),
      ]);

      expect(tree, hasLength(1));
      expect(tree.first.subcategories, isEmpty);
    });

    test('a root with no children keeps an empty subcategories list', () {
      final tree = buildCategoryTree([_row(id: 1)]);

      expect(tree.first.subcategories, isEmpty);
    });
  });
}
