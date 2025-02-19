import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/budget_category.dart';

class GetBudgetCategoriesUseCase extends BaseUseCase {
  GetBudgetCategoriesUseCase() : super('GetBudgetCategories');
  Future<HandleResult<List<BudgetCategory>>> execute() async {
    HandleResult<List<BudgetCategory>> result =
        HandleResult<List<BudgetCategory>>();
    return result;
  }
}
