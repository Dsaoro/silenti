import 'package:flutter/foundation.dart';
import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/financial_asset.dart';
import 'package:silenti/infraestructure/storage/financial_assets_dao.dart';

class GetFinancialAssets extends BaseUseCase {
  GetFinancialAssets() : super("GetFinancialAssets");

  Future<HandleResult<List<FinancialAsset>>> execute() async {
    FinancialAssetsDao dao = FinancialAssetsDao();
    HandleResult<List<FinancialAsset>> result =
        HandleResult<List<FinancialAsset>>();
    List<FinancialAsset> assets = [];
    try {
      await dao.getAccounts().then((value) {
        for (var element in value) {
          assets.add(FinancialAsset.fromMap(element));
          if (kDebugMode) {
            print(element.toString());
          }
        }
        return assets;
      });
    } catch (e) {
      if (kDebugMode) {
        print("error in getFinancialAssets: $e");
      }
      result.setError(e.toString());
      return result;
    }
    if (kDebugMode) {
      print("assets response legth: ${assets.length}");
    }
    result.setData(assets);
    return result;
  }
}
