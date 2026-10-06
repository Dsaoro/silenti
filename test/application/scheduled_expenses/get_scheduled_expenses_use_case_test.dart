import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/application/scheduled_expenses/get_scheduled_expenses_use_case.dart';
import 'package:silenti/infraestructure/storage/scheduled_expenses_dao.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late GetScheduledExpensesUseCase useCase;

  setUp(() async {
    db = await openTestDatabase();
    useCase = GetScheduledExpensesUseCase(
      dao: ScheduledExpensesDao(databaseProvider: () async => db),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seed(String name, int dueDay, {int active = 1}) {
    return db.insert('scheduled_expenses', {
      'categoryId': 1,
      'name': name,
      'dueDay': dueDay,
      'reminderDaysBefore': 3,
      'active': active,
    }).then((_) {});
  }

  test('returns only active expenses, sorted by next due date', () async {
    await seed('Tarjeta (día 25)', 25);
    await seed('Arriendo (día 5)', 5);
    await seed('Internet (día 15)', 15);
    await seed('Inactivo', 1, active: 0);

    final result = await useCase.execute(now: DateTime(2026, 3, 1));

    expect(result.status, isTrue);
    expect(result.model!.map((e) => e.name),
        ['Arriendo (día 5)', 'Internet (día 15)', 'Tarjeta (día 25)']);
  });

  test('an empty list is a success, not an error', () async {
    final result = await useCase.execute();

    expect(result.status, isTrue);
    expect(result.model, isEmpty);
  });
}
