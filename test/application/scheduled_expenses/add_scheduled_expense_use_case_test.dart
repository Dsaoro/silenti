import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:silenti/application/scheduled_expenses/add_scheduled_expense_use_case.dart';
import 'package:silenti/core/models/scheduled_expense.dart';
import 'package:silenti/infraestructure/adapters/local_notifications_service.dart';
import 'package:silenti/infraestructure/storage/scheduled_expenses_dao.dart';

class MockScheduledExpensesDao extends Mock implements ScheduledExpensesDao {}

class MockLocalNotificationsService extends Mock
    implements LocalNotificationsService {}

void main() {
  late MockScheduledExpensesDao dao;
  late MockLocalNotificationsService notifications;
  late AddScheduledExpenseUseCase useCase;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    dao = MockScheduledExpensesDao();
    notifications = MockLocalNotificationsService();
    when(() => notifications.scheduleReminder(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          dateTime: any(named: 'dateTime'),
        )).thenAnswer((_) async {});
    useCase = AddScheduledExpenseUseCase(dao: dao, notifications: notifications);
  });

  test('schedules a reminder when the new expense is active', () async {
    when(() => dao.insert(any())).thenAnswer((_) async => 7);

    final result = await useCase.execute(ScheduledExpense(
      id: 0,
      categoryId: 1,
      name: 'Arriendo',
      dueDay: 5,
      reminderDaysBefore: 3,
    ));

    expect(result.status, isTrue);
    expect(result.model, 7);
    verify(() => notifications.scheduleReminder(
          id: 7,
          title: any(named: 'title'),
          body: any(named: 'body'),
          dateTime: any(named: 'dateTime'),
        )).called(1);
  });

  test('does not schedule a reminder when the expense is created inactive',
      () async {
    when(() => dao.insert(any())).thenAnswer((_) async => 8);

    await useCase.execute(ScheduledExpense(
      id: 0,
      categoryId: 1,
      name: 'Arriendo',
      dueDay: 5,
      reminderDaysBefore: 3,
      active: false,
    ));

    verifyNever(() => notifications.scheduleReminder(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          dateTime: any(named: 'dateTime'),
        ));
  });

  test('reports failure when the DAO cannot insert the row', () async {
    when(() => dao.insert(any())).thenAnswer((_) async => 0);

    final result = await useCase.execute(ScheduledExpense(
      id: 0,
      categoryId: 1,
      name: 'Arriendo',
      dueDay: 5,
      reminderDaysBefore: 3,
    ));

    expect(result.status, isFalse);
  });
}
