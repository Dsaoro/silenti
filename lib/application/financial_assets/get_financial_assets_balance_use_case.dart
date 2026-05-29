import 'package:flutter/foundation.dart';
import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/infraestructure/storage/financial_assets_dao.dart';

class GetFinancialAssetsBalanceUseCase extends BaseUseCase {
  GetFinancialAssetsBalanceUseCase()
      : super('GetFinancialAssetsBalanceUseCase');
  Future<HandleResult<double>> execute() async {
    HandleResult<double> result = HandleResult<double>();
    double balance = 0;
    // Here we would get the balance from the database
    // and return it in the result
    try {
      await FinancialAssetsDao().getAccountBalance().then((value) {
        if (value.first.keys.contains('balance')) {
          var response = value.first['balance'];
          if (kDebugMode) {
            print("balance retrieved: $response, ${response.runtimeType}");
          }
          balance = double.parse(response.toString());
        }
      });
    } catch (e) {
      result.setError(e.toString());
      if (kDebugMode) {
        print("error getting balance${result.message}");
      }
      return result;
    }
    result.setData(balance);
    return result;
  }
}
