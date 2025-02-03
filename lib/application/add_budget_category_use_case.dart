import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/budget_category.dart';

class AddBudgetCategoryUseCase extends BaseUseCase {
  AddBudgetCategoryUseCase() : super('AddBudgetCategory');
  Future<HandleResult<bool>> execute(
      {required BudgetCategory budgetCategory}) async {
    HandleResult<bool> result = HandleResult<bool>();
    return result;
  }
}
