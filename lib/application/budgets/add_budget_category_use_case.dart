import 'package:flutter/foundation.dart';
import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/budget_category.dart';
import 'package:silenti/infraestructure/storage/budget_categories_dao.dart';

class AddBudgetCategoryUseCase extends BaseUseCase {
  AddBudgetCategoryUseCase() : super('AddBudgetCategory');
  Future<HandleResult<int>> execute({required BudgetCategory category}) async {
    HandleResult<int> result = HandleResult<int>();
    BudgetCategoriesDAO dao = BudgetCategoriesDAO();
    try {
      var response = await dao.insertBudgetCategory(category.toMap());
      if (response > 0) {
        result.setData(response);
        if (kDebugMode) {
          print("Added Budget with Id on AddBudgetCategory: $response");
        }
      }
    } catch (e) {
      result.setError("Error in AddBudgetCategory");
      if (kDebugMode) {
        print(result.message);
        print(e.toString());
      }
    }

    return result;
  }
}
