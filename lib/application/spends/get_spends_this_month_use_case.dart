import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/infraestructure/storage/operation_dao.dart';

class GetSpendsThisMonthUseCase extends BaseUseCase {
  GetSpendsThisMonthUseCase() : super("GetSpendsThisMonth");
  Future<HandleResult<double>> execute() async {
    HandleResult<double> result = HandleResult<double>();
    OperationDAO dao = OperationDAO();
    double amount = 0.0;
    var now = DateTime.now();
    try {
      await dao.getSpendByMonth(month: now.month, year: now.year).then(
        (value) {
          if (value.first.keys.contains('amount')) {
            amount = double.parse(value.first['amount'].toString());
            result.setData(amount);
            return result;
          } else {
            amount = 0.0;
          }
        },
      );
    } catch (e) {
      result.setError(e.toString());
      return result;
    }
    return result;
  }
}
