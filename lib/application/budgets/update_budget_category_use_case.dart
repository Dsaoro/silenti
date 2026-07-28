import 'package:flutter/foundation.dart';
import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/budget_category.dart';
import 'package:silenti/infraestructure/storage/budget_categories_dao.dart';

class UpdateBudgetCategoryUseCase extends BaseUseCase {
  UpdateBudgetCategoryUseCase() : super('UpdateBudgetCategory');

  Future<HandleResult<int>> execute({required BudgetCategory category}) async {
    HandleResult<int> result = HandleResult<int>();
    BudgetCategoriesDAO dao = BudgetCategoriesDAO();
    try {
      var response = await dao.updateBudgetCategory(category.toMap());
      if (response > 0) {
        result.setData(response);
        if (kDebugMode) {
          print("Updated Budget with Id on UpdateBudgetCategory: $response");
        }
      } else {
        result.setError("Budget Category not found or not updated");
      }
    } catch (e) {
      result.setError("Error in UpdateBudgetCategory");
      if (kDebugMode) {
        print(result.message);
        print(e.toString());
      }
    }

    return result;
  }
}
