import 'package:silenti/core/models/budget_category.dart';

/// Builds a category → subcategory tree from a flat list of
/// `budget_categories` rows, shared by [GetExpensesCategoriesUseCase] and
/// [GetIncomeCategoriesUseCase] so both apply the same rule.
///
/// The tree is capped at 2 levels on purpose (PRD.md H1.2,
/// BUSINESS_LOGIC_AUDIT.md #3.8): a row whose parent is itself a child
/// (i.e. a would-be 3rd level / grandchild) is dropped, not attached. This
/// used to happen by accident because [GetExpensesCategoriesUseCase] only
/// ever looked one level deep — now it's an explicit, tested rule.
List<BudgetCategory> buildCategoryTree(List<Map<String, dynamic>> rows) {
  final allCategories = rows.map(BudgetCategory.fromMap).toList();
  final byId = {for (final c in allCategories) c.id: c};

  final roots = <BudgetCategory>[];
  final childrenByParent = <int, List<BudgetCategory>>{};

  for (final category in allCategories) {
    if (category.parentId == null) {
      roots.add(category);
      continue;
    }

    final parent = byId[category.parentId];
    if (parent != null && parent.parentId == null) {
      // parent is a root, so `category` is a valid 2nd-level subcategory.
      childrenByParent.putIfAbsent(category.parentId!, () => []).add(category);
    }
    // else: either an orphan (parentId doesn't match any row) or a would-be
    // 3rd level (its parent is itself a child) — deliberately dropped.
  }

  return roots
      .map((root) =>
          root.copyWith(subcategories: childrenByParent[root.id] ?? []))
      .toList();
}
