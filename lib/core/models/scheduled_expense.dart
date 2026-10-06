/// A recurring, periodic expense the user wants to be reminded of
/// (PRD.md H3.1–H3.4) — e.g. "Arriendo, día 5 de cada mes". It never
/// creates an `Operation` by itself; it only drives the timeline view and
/// the OS push reminder. The user still registers the real transaction
/// manually (PRD.md §5 decision).
class ScheduledExpense {
  final int id;
  final int categoryId;
  final String name;

  /// Day of the month this expense is due, 1-31. Clamped to the real last
  /// day of shorter months (e.g. 31 in February becomes the 28th/29th).
  final int dueDay;

  /// How many days before the due date the reminder should fire.
  final int reminderDaysBefore;
  final bool active;

  ScheduledExpense({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.dueDay,
    required this.reminderDaysBefore,
    this.active = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id == 0 ? null : id, // Auto-increment
        'categoryId': categoryId,
        'name': name,
        'dueDay': dueDay,
        'reminderDaysBefore': reminderDaysBefore,
        'active': active ? 1 : 0,
      };

  factory ScheduledExpense.fromMap(Map<String, dynamic> map) =>
      ScheduledExpense(
        id: map['id'],
        categoryId: map['categoryId'],
        name: map['name'],
        dueDay: map['dueDay'],
        reminderDaysBefore: map['reminderDaysBefore'],
        active: (map['active'] ?? 1) == 1,
      );

  /// The next occurrence of [dueDay] on or after [from] (defaults to now).
  DateTime nextDueDate({DateTime? from}) {
    final today = from ?? DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    final thisMonthDue = _clampedDate(today.year, today.month, dueDay);
    if (!thisMonthDue.isBefore(todayDateOnly)) {
      return thisMonthDue;
    }

    final nextMonth = DateTime(today.year, today.month + 1, 1);
    return _clampedDate(nextMonth.year, nextMonth.month, dueDay);
  }

  /// The date the push reminder for the next occurrence should fire.
  DateTime nextReminderDate({DateTime? from}) {
    return nextDueDate(from: from).subtract(Duration(days: reminderDaysBefore));
  }

  static DateTime _clampedDate(int year, int month, int day) {
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day > lastDayOfMonth ? lastDayOfMonth : day);
  }
}
