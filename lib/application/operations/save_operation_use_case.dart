import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/infraestructure/storage/operation_dao.dart';

/// Shared validation for any code path that persists an [Operation]
/// (BUSINESS_LOGIC_AUDIT.md #4.4): rejects the "not selected" category
/// placeholder (id 0, used by the forms' dropdowns) and non-positive
/// amounts before anything touches the database.
///
/// Used by [SaveOperationUSeCase] and by DepositInFinancialAssetUseCase /
/// WithdrawFromFinancialAssetUseCase — those two no longer route through
/// [SaveOperationUSeCase] (they call FinancialAssetsDao.applyOperation
/// directly for atomicity, BUSINESS_LOGIC_AUDIT.md #3.3) but must still
/// apply this same rule.
String? validateOperationForSave(Operation operation) {
  if (operation.category <= 0) {
    return "A category must be selected";
  }
  if (operation.amount <= 0) {
    return "Amount must be greater than zero";
  }
  return null;
}

class SaveOperationUSeCase extends BaseUseCase {
  final OperationDAO dao;
  SaveOperationUSeCase({OperationDAO? dao})
      : dao = dao ?? OperationDAO(),
        super('SaveOperation');
  Future<HandleResult<int>> execute({required Operation operation}) async {
    HandleResult<int> result = HandleResult<int>();
    final validationError = validateOperationForSave(operation);
    if (validationError != null) {
      result.setError(validationError);
      return result;
    }
    var operationId = await dao.insertOperation(
      operation.toMap(),
    );
    if (operationId != 0) {
      result.setData(operationId);
    } else {
      result.setError("Operation could not be registered");
    }
    return result;
  }
}
