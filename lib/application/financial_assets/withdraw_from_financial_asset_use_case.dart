import 'package:flutter/foundation.dart';
import 'package:silenti/application/operations/save_operation_use_case.dart';
import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/infraestructure/storage/financial_assets_dao.dart';

class WithdrawFromFinancialAssetUseCase extends BaseUseCase {
  WithdrawFromFinancialAssetUseCase() : super("DepositInFinancialAssetUseCase");
  Future<HandleResult<bool>> execute(Operation operation) async {
    HandleResult<bool> result = HandleResult<bool>();
    if (operation.type != "spent") {
      return result;
    }
    FinancialAssetsDao dao = FinancialAssetsDao();
    var withdrawResponse = await dao.withdraw(
        financialAsset: operation.financialAsset, amount: operation.amount);
    if (kDebugMode) {
      print(" response from withdraw ${withdrawResponse.toString()}");
    }
    // if (withdrawResponse.isEmpty) {
    //   result.setError("withdraw cannot be executed, please try again");
    //   if (kDebugMode) {
    //     print(result.message);
    //   }
    //   return result;
    // }
    var response = await SaveOperationUSeCase().execute(operation: operation);
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
