import 'package:flutter/foundation.dart';
import 'package:silenti/application/operations/save_operation_use_case.dart';
import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/infraestructure/storage/financial_assets_dao.dart';

class DepositInFinancialAssetUseCase extends BaseUseCase {
  DepositInFinancialAssetUseCase() : super("DepositInFinancialAssetUseCase");
  Future<HandleResult<bool>> execute(Operation operation) async {
    HandleResult<bool> result = HandleResult<bool>();
    if (operation.type != "income") {
      result.setError("Operation type must be 'income' for deposits");
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
    var depositResponse = await dao.deposit(
      financialAsset: operation.financialAsset,
      amount: operation.amount,
      operationId:
          saveOperationResponse.model, // Usar el ID de la operación guardada
    );

    if (kDebugMode) {
      print("Response from deposit ${depositResponse.toString()}");
      print(
          "Operation stored successfully with ID: ${saveOperationResponse.model}");
    }

    result.setData(true);
    return result;
  }
}
