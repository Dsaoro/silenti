import 'package:flutter/foundation.dart';
import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/infraestructure/storage/financial_assets_dao.dart';

class DeleteFinancialAssetUseCase extends BaseUseCase {
  final FinancialAssetsDao dao;
  DeleteFinancialAssetUseCase({FinancialAssetsDao? dao})
      : dao = dao ?? FinancialAssetsDao(),
        super("DeleteFinancialAsset");
  Future<HandleResult<int>> execute(int id) async {
    HandleResult<int> result = HandleResult<int>();
    try {
      var response = await dao.deleteAccountById(id);
      //TODO save log for Asset Creation
      if (kDebugMode) {
        print("Deleted row on DeleteFinancialAsset: $response");
      }
      result.setData(response);
    } catch (e) {
      result.setError("Error in CreateFinancialAssetUseCase");
      if (kDebugMode) {
        print(result.message);
      }
    }

    return result;
  }
}
