import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/spend_sub_categories.dart';
import 'package:silenti/infraestructure/storage/spend_sub_categories_dao.dart';

class GetExpensesSubCategoriesUseCase extends BaseUseCase {
  GetExpensesSubCategoriesUseCase() : super("GetExpensesSubCategories");

  Future<HandleResult<List<SpendSubCategories>>> execute() async {
    HandleResult<List<SpendSubCategories>> result =
        HandleResult<List<SpendSubCategories>>();
    List<SpendSubCategories> categories = [];
    var dao = SpendSubCategoriesDao();
    try {
      await dao.getAll().then((value) {
        for (var element in value) {
          categories.add(SpendSubCategories.fromMap(element));
        }
        result.setData(categories);
      });
    } catch (e) {
      result.setError(e.toString());
    }
    return result;
  }

  Future<HandleResult<List<SpendSubCategories>>> byId({required int id}) async {
    HandleResult<List<SpendSubCategories>> result =
        HandleResult<List<SpendSubCategories>>();
    List<SpendSubCategories> categories = [];
    var dao = SpendSubCategoriesDao();
    try {
      await dao.getByCategoryId(id: id).then((value) {
        for (var element in value) {
          categories.add(SpendSubCategories.fromMap(element));
        }
        result.setData(categories);
      });
    } catch (e) {
      result.setError(e.toString());
    }
    return result;
  }
}
