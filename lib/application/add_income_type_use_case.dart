import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/income.dart';

class AddIncomeTypeUseCase extends BaseUseCase {
  AddIncomeTypeUseCase() : super('AddIncomeType');
  Future<HandleResult<bool>> execute({required Income income}) async {
    HandleResult<bool> result = HandleResult<bool>();
    return result;
  }
}
