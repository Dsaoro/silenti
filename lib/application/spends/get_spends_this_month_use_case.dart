import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/infraestructure/storage/operation_dao.dart';

class GetSpendsThisMonthUseCase extends BaseUseCase {
  final OperationDAO dao;
  GetSpendsThisMonthUseCase({OperationDAO? dao})
      : dao = dao ?? OperationDAO(),
        super("GetSpendsThisMonth");
  Future<HandleResult<double>> execute() async {
    HandleResult<double> result = HandleResult<double>();
    var now = DateTime.now();
    try {
      final rows = await dao.getSpendByMonth(month: now.month, year: now.year);
      // getSpendByMonth always returns exactly one row now
      // (BUSINESS_LOGIC_AUDIT.md #3.6) — a month with no operations is 0.0,
      // a valid successful result, not an error.
      final amount = double.parse(rows.first['amount'].toString());
      result.setData(amount);
    } catch (e) {
      result.setError(e.toString());
    }
    return result;
  }
}
