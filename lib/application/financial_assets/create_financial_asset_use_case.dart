import 'package:flutter/foundation.dart';
import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/financial_asset.dart';
import 'package:silenti/infraestructure/storage/financial_assets_dao.dart';

class CreateFinancialAssetUseCase extends BaseUseCase {
  CreateFinancialAssetUseCase() : super("CreateFinancialAsset");
  Future<HandleResult<int>> execute(FinancialAsset asset) async {
    HandleResult<int> result = HandleResult<int>();
    try {
      FinancialAssetsDao dao = FinancialAssetsDao();
      if (kDebugMode) {
        print(asset.toMap());
      }
      var response = await dao.insertAccount(asset.toMap());
      //TODO save log for Asset Creation
      if (kDebugMode) {
        print("Added Account Id on CreateFinancialAsset: $response");
      }
      result.setData(response);
    } catch (e) {
      result.setError("Error in CreateFinancialAssetUseCase");
    }

    return result;
  }
}
