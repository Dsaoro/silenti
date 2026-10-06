import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/scheduled_expense.dart';
import 'package:silenti/infraestructure/storage/scheduled_expenses_dao.dart';

class GetScheduledExpensesUseCase extends BaseUseCase {
  final ScheduledExpensesDao dao;
  GetScheduledExpensesUseCase({ScheduledExpensesDao? dao})
      : dao = dao ?? ScheduledExpensesDao(),
        super('GetScheduledExpenses');

  /// Active scheduled expenses, in timeline order (soonest due date
  /// first) — PRD.md H3.2. [now] is only for tests; production callers
  /// leave it out.
  Future<HandleResult<List<ScheduledExpense>>> execute({DateTime? now}) async {
    HandleResult<List<ScheduledExpense>> result =
        HandleResult<List<ScheduledExpense>>();
    try {
      final rows = await dao.getActive();
      final expenses = rows.map(ScheduledExpense.fromMap).toList()
        ..sort((a, b) => a
            .nextDueDate(from: now)
            .compareTo(b.nextDueDate(from: now)));
      result.setData(expenses);
    } catch (e) {
      result.setError(e.toString());
    }
    return result;
  }
}
