import 'package:flutter/foundation.dart';
import 'package:silenti/application/operations/save_operation_use_case.dart';
import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/infraestructure/storage/financial_assets_dao.dart';

class WithdrawFromFinancialAssetUseCase extends BaseUseCase {
  WithdrawFromFinancialAssetUseCase()
      : super("WithdrawFromFinancialAssetUseCase");
  Future<HandleResult<bool>> execute(Operation operation) async {
    HandleResult<bool> result = HandleResult<bool>();
    if (operation.type != "spent") {
      result.setError("Operation type must be 'spent' for withdrawals");
      return result;
    }

    // Primero guardamos la operación para obtener el ID
    var saveOperationResponse = await SaveOperationUSeCase().execute(
      operation: operation,
    );

    if (!saveOperationResponse.status) {
      result.setError("Failed to save operation");
      return result;
    }

    // Luego actualizamos el balance del activo financiero con el ID de la operación
    FinancialAssetsDao dao = FinancialAssetsDao();
    var withdrawResponse = await dao.withdraw(
      financialAsset: operation.financialAsset,
      amount: operation.amount,
      operationId:
          saveOperationResponse.model, // Usar el ID de la operación guardada
    );

    if (kDebugMode) {
      print("Response from withdraw ${withdrawResponse.toString()}");
      print(
          "Operation stored successfully with ID: ${saveOperationResponse.model}");
    }

    result.setData(true);
    return result;
  }
}
