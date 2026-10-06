import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/scheduled_expense.dart';
import 'package:silenti/infraestructure/adapters/local_notifications_service.dart';
import 'package:silenti/infraestructure/storage/scheduled_expenses_dao.dart';

class UpdateScheduledExpenseUseCase extends BaseUseCase {
  final ScheduledExpensesDao dao;
  final LocalNotificationsService notifications;
  UpdateScheduledExpenseUseCase({
    ScheduledExpensesDao? dao,
    LocalNotificationsService? notifications,
  })  : dao = dao ?? ScheduledExpensesDao(),
        notifications = notifications ?? LocalNotificationsService(),
        super('UpdateScheduledExpense');

  Future<HandleResult<int>> execute(ScheduledExpense expense) async {
    HandleResult<int> result = HandleResult<int>();
    try {
      final updated = await dao.update(expense.id, expense.toMap());
      if (updated > 0) {
        result.setData(updated);
        // Re-scheduling replaces any previously scheduled reminder with
        // the same id, so day/lead-time edits take effect immediately.
        if (expense.active) {
          await notifications.scheduleReminder(
            id: expense.id,
            title: expense.name,
            body: 'Vence el ${expense.nextDueDate().day}',
            dateTime: expense.nextReminderDate(),
          );
        } else {
          await notifications.cancelReminder(expense.id);
        }
      } else {
        result.setError('Scheduled expense not found');
      }
    } catch (e) {
      result.setError('Error in UpdateScheduledExpenseUseCase');
    }
    return result;
  }
}
