import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/budget_category.dart';
import 'package:silenti/infraestructure/storage/budget_categories_dao.dart';

class GetExpensesCategoriesUseCase extends BaseUseCase {
  GetExpensesCategoriesUseCase() : super('GetBudgetCategories');
  Future<HandleResult<List<BudgetCategory>>> execute() async {
    HandleResult<List<BudgetCategory>> result =
        HandleResult<List<BudgetCategory>>();
    List<BudgetCategory> categories = [];
    var dao = BudgetCategoriesDAO();
    try {
      await dao.getBudgetExpenses().then((value) {
        for (var element in value) {
          categories.add(BudgetCategory.fromMap(element));
        }
        result.setData(categories);
      });
    } catch (e) {
      result.setError(e.toString());
    }
    return result;
  }
}
