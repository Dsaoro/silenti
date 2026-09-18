import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/financial_asset.dart';
import 'package:silenti/infraestructure/storage/financial_assets_dao.dart';

class FinancialAssetsUpdateUseCase extends BaseUseCase {
  final FinancialAssetsDao dao;
  FinancialAssetsUpdateUseCase({FinancialAssetsDao? dao})
      : dao = dao ?? FinancialAssetsDao(),
        super("FinancialAssetsUpdateUseCase");

  Future<HandleResult<int>> execute(FinancialAsset asset) async {
    HandleResult<int> result = HandleResult<int>();
    try {
      final updated = await dao.updateAccountById(asset.id, asset.toMap());
      if (updated > 0) {
        result.setData(updated);
      } else {
        result.setError("Financial asset not found");
      }
    } catch (e) {
      result.setError("Error in FinancialAssetsUpdateUseCase");
    }
    return result;
  }
}
