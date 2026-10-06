import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/scheduled_expense.dart';
import 'package:silenti/infraestructure/adapters/local_notifications_service.dart';
import 'package:silenti/infraestructure/storage/scheduled_expenses_dao.dart';

class AddScheduledExpenseUseCase extends BaseUseCase {
  final ScheduledExpensesDao dao;
  final LocalNotificationsService notifications;
  AddScheduledExpenseUseCase({
    ScheduledExpensesDao? dao,
    LocalNotificationsService? notifications,
  })  : dao = dao ?? ScheduledExpensesDao(),
        notifications = notifications ?? LocalNotificationsService(),
        super('AddScheduledExpense');

  Future<HandleResult<int>> execute(ScheduledExpense expense) async {
    HandleResult<int> result = HandleResult<int>();
    try {
      final id = await dao.insert(expense.toMap());
      if (id > 0) {
        result.setData(id);
        if (expense.active) {
          final withId = ScheduledExpense(
            id: id,
            categoryId: expense.categoryId,
            name: expense.name,
            dueDay: expense.dueDay,
            reminderDaysBefore: expense.reminderDaysBefore,
            active: expense.active,
          );
          await notifications.scheduleReminder(
            id: id,
            title: withId.name,
            body: 'Vence el ${withId.nextDueDate().day}',
            dateTime: withId.nextReminderDate(),
          );
        }
      } else {
        result.setError('Scheduled expense could not be registered');
      }
    } catch (e) {
      result.setError('Error in AddScheduledExpenseUseCase');
    }
    return result;
  }
}
