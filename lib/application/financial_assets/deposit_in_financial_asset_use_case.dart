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
      return result;
    }
    FinancialAssetsDao dao = FinancialAssetsDao();
    var depositResponse = await dao.deposit(
        financialAsset: operation.financialAsset, amount: operation.amount);
    if (kDebugMode) {
      print(" response from deposit ${depositResponse.toString()}");
    }
    // if (depositResponse.isEmpty) {
    //   result.setError("deposit cannot be added, please try again");
    //   if (kDebugMode) {
    //     print(result.message);
    //   }
    //   return result;
    // }
    var response = await SaveOperationUSeCase().execute(
      operation: operation,
    );
    result.setData(true);
    if (kDebugMode) {
      print("Store operation sucessfuly");
    }
    if (kDebugMode) {
      print(response);
    }
    return result;
  }
}
