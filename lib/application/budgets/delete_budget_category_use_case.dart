import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/budget_category.dart';

class DeleteBudgetCategoryUseCase extends BaseUseCase {
  DeleteBudgetCategoryUseCase() : super("DeleteBudgetCategory");
  Future<HandleResult<int>> execute(BudgetCategory budget) async {
    HandleResult<int> result = HandleResult<int>();
    return result;
  }
}
