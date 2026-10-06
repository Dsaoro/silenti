import 'package:flutter_test/flutter_test.dart';
import 'package:silenti/core/models/scheduled_expense.dart';

ScheduledExpense _expense({int dueDay = 5, int reminderDaysBefore = 3}) {
  return ScheduledExpense(
    id: 1,
    categoryId: 1,
    name: 'Arriendo',
    dueDay: dueDay,
    reminderDaysBefore: reminderDaysBefore,
  );
}

void main() {
  group('ScheduledExpense.nextDueDate', () {
    test('returns this month\'s due date when it has not passed yet', () {
      final expense = _expense(dueDay: 20);

      expect(expense.nextDueDate(from: DateTime(2026, 3, 10)),
          DateTime(2026, 3, 20));
    });

    test('today counts as the due date if it matches exactly', () {
      final expense = _expense(dueDay: 10);

      expect(expense.nextDueDate(from: DateTime(2026, 3, 10)),
          DateTime(2026, 3, 10));
    });

    test('rolls over to next month once the due day has passed', () {
      final expense = _expense(dueDay: 5);

      expect(expense.nextDueDate(from: DateTime(2026, 3, 10)),
          DateTime(2026, 4, 5));
    });

    test('rolls over from December to January of the next year', () {
      final expense = _expense(dueDay: 5);

      expect(expense.nextDueDate(from: DateTime(2026, 12, 10)),
          DateTime(2027, 1, 5));
    });

    test('clamps dueDay 31 to February\'s real last day', () {
      final expense = _expense(dueDay: 31);

      // 2026 is not a leap year — Feb has 28 days.
      expect(expense.nextDueDate(from: DateTime(2026, 2, 1)),
          DateTime(2026, 2, 28));
    });

    test('clamps dueDay 31 to February 29 on a leap year', () {
      final expense = _expense(dueDay: 31);

      expect(expense.nextDueDate(from: DateTime(2028, 2, 1)),
          DateTime(2028, 2, 29));
    });
  });

  group('ScheduledExpense.nextReminderDate', () {
    test('is the due date minus the configured lead time', () {
      final expense = _expense(dueDay: 20, reminderDaysBefore: 3);

      expect(expense.nextReminderDate(from: DateTime(2026, 3, 1)),
          DateTime(2026, 3, 17));
    });

    test('a 0-day lead time means the reminder fires on the due date itself',
        () {
      final expense = _expense(dueDay: 20, reminderDaysBefore: 0);

      expect(expense.nextReminderDate(from: DateTime(2026, 3, 1)),
          DateTime(2026, 3, 20));
    });
  });
}
