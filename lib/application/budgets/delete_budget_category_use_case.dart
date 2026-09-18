import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/budget_category.dart';
import 'package:silenti/infraestructure/storage/budget_categories_dao.dart';
import 'package:silenti/infraestructure/storage/operation_dao.dart';

class DeleteBudgetCategoryUseCase extends BaseUseCase {
  final BudgetCategoriesDAO dao;
  final OperationDAO operationDao;
  DeleteBudgetCategoryUseCase({
    BudgetCategoriesDAO? dao,
    OperationDAO? operationDao,
  })  : dao = dao ?? BudgetCategoriesDAO(),
        operationDao = operationDao ?? OperationDAO(),
        super("DeleteBudgetCategory");

  Future<HandleResult<int>> execute(BudgetCategory budget) async {
    HandleResult<int> result = HandleResult<int>();
    try {
      final children = await dao.getChildren(budget.id);
      if (children.isNotEmpty) {
        result.setError(
            "Category has subcategories; remove them before deleting it");
        return result;
      }

      final relatedOperations = await operationDao
          .getOperationsByBudgetCategoryLimited(budget.id, limit: 1);
      if (relatedOperations.isNotEmpty) {
        result.setError(
            "Category has transactions associated with it and can't be deleted");
        return result;
      }

      final deleted = await dao.deleteBudgetCategory(budget.id);
      if (deleted > 0) {
        result.setData(deleted);
      } else {
        result.setError("Category not found");
      }
    } catch (e) {
      result.setError("Error in DeleteBudgetCategory");
    }
    return result;
  }
}
