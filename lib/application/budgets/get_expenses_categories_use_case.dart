import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/budget_category.dart';
import 'package:silenti/infraestructure/storage/budget_categories_dao.dart';

class GetExpensesCategoriesUseCase extends BaseUseCase {
  GetExpensesCategoriesUseCase() : super('GetBudgetCategories');
  Future<HandleResult<List<BudgetCategory>>> execute() async {
    HandleResult<List<BudgetCategory>> result =
        HandleResult<List<BudgetCategory>>();
    List<BudgetCategory> allCategories = [];
    var dao = BudgetCategoriesDAO();
    try {
      await dao.getBudgetExpenses().then((value) {
        for (var element in value) {
          allCategories.add(BudgetCategory.fromMap(element));
        }

        // Build hierarchy
        List<BudgetCategory> parents = [];
        Map<int, List<BudgetCategory>> childrenMap = {};

        // Group by parentId
        for (var category in allCategories) {
          if (category.parentId == null) {
            parents.add(category);
          } else {
            childrenMap.putIfAbsent(category.parentId!, () => []).add(category);
          }
        }

        // Assign children to parents
        List<BudgetCategory> resultCategories = [];
        for (var parent in parents) {
          var children = childrenMap[parent.id] ?? [];
          resultCategories.add(parent.copyWith(subcategories: children));
        }

        result.setData(resultCategories);
      });
    } catch (e) {
      result.setError(e.toString());
    }
    return result;
  }
}
