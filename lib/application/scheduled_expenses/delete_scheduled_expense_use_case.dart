import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/infraestructure/adapters/local_notifications_service.dart';
import 'package:silenti/infraestructure/storage/scheduled_expenses_dao.dart';

class DeleteScheduledExpenseUseCase extends BaseUseCase {
  final ScheduledExpensesDao dao;
  final LocalNotificationsService notifications;
  DeleteScheduledExpenseUseCase({
    ScheduledExpensesDao? dao,
    LocalNotificationsService? notifications,
  })  : dao = dao ?? ScheduledExpensesDao(),
        notifications = notifications ?? LocalNotificationsService(),
        super('DeleteScheduledExpense');

  Future<HandleResult<int>> execute(int id) async {
    HandleResult<int> result = HandleResult<int>();
    try {
      final deleted = await dao.delete(id);
      if (deleted > 0) {
        await notifications.cancelReminder(id);
        result.setData(deleted);
      } else {
        result.setError('Scheduled expense not found');
      }
    } catch (e) {
      result.setError('Error in DeleteScheduledExpenseUseCase');
    }
    return result;
  }
}
