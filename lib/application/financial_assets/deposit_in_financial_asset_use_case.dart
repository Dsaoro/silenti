import 'package:flutter/foundation.dart';
import 'package:silenti/application/operations/save_operation_use_case.dart';
import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/infraestructure/storage/financial_assets_dao.dart';

class DepositInFinancialAssetUseCase extends BaseUseCase {
  final FinancialAssetsDao dao;
  DepositInFinancialAssetUseCase({FinancialAssetsDao? dao})
      : dao = dao ?? FinancialAssetsDao(),
        super("DepositInFinancialAssetUseCase");

  Future<HandleResult<bool>> execute(Operation operation) async {
    HandleResult<bool> result = HandleResult<bool>();
    if (operation.type != Operation.income) {
      result.setError("Operation type must be 'income' for deposits");
      return result;
    }

    final validationError = validateOperationForSave(operation);
    if (validationError != null) {
      result.setError(validationError);
      return result;
    }

    // Inserta la operación, actualiza el saldo y registra el historial de
    // forma atómica (BUSINESS_LOGIC_AUDIT.md #3.3).
    final applied = await dao.applyOperation(
      operationData: operation.toMap(),
      financialAsset: operation.financialAsset,
      amount: operation.amount,
      isDeposit: true,
    );

    if (applied == null) {
      // El activo no existe: no se escribió nada (BUSINESS_LOGIC_AUDIT.md
      // #3.2 — antes esto se reportaba como éxito de todas formas).
      result.setError("Financial asset not found");
      return result;
    }

    if (kDebugMode) {
      print(
          "Deposit applied: operationId=${applied.operationId} newBalance=${applied.newBalance}");
    }

    result.setData(true);
    return result;
  }
}
