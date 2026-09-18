import 'package:silenti/application/budgets/budget_category_tree.dart';
import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/budget_category.dart';
import 'package:silenti/infraestructure/storage/budget_categories_dao.dart';

/// Replaces the old `GetIncomeTypesUseCase` stub
/// (BUSINESS_LOGIC_AUDIT.md #3.5): income categories are real
/// `BudgetCategory` rows (`type: 'income'`), listed the same way expense
/// categories are.
class GetIncomeCategoriesUseCase extends BaseUseCase {
  final BudgetCategoriesDAO dao;
  GetIncomeCategoriesUseCase({BudgetCategoriesDAO? dao})
      : dao = dao ?? BudgetCategoriesDAO(),
        super('GetIncomeCategories');
  Future<HandleResult<List<BudgetCategory>>> execute() async {
    HandleResult<List<BudgetCategory>> result =
        HandleResult<List<BudgetCategory>>();
    try {
      final rows = await dao.getBudgetIncomes();
      result.setData(buildCategoryTree(rows));
    } catch (e) {
      result.setError(e.toString());
    }
    return result;
  }
}
