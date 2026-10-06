import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/infraestructure/storage/scheduled_expenses_dao.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late ScheduledExpensesDao dao;

  setUp(() async {
    db = await openTestDatabase();
    dao = ScheduledExpensesDao(databaseProvider: () async => db);
  });

  tearDown(() async {
    await db.close();
  });

  Map<String, dynamic> data({
    int categoryId = 1,
    String name = 'Arriendo',
    int dueDay = 5,
    int reminderDaysBefore = 3,
    int active = 1,
  }) {
    return {
      'categoryId': categoryId,
      'name': name,
      'dueDay': dueDay,
      'reminderDaysBefore': reminderDaysBefore,
      'active': active,
    };
  }

  test('insert + getAll round-trip', () async {
    await dao.insert(data());

    final all = await dao.getAll();

    expect(all, hasLength(1));
    expect(all.first['name'], 'Arriendo');
  });

  test('getActive excludes inactive scheduled expenses', () async {
    await dao.insert(data(name: 'Activo', active: 1));
    await dao.insert(data(name: 'Inactivo', active: 0));

    final active = await dao.getActive();

    expect(active, hasLength(1));
    expect(active.first['name'], 'Activo');
  });

  test('update changes the stored row', () async {
    final id = await dao.insert(data(dueDay: 5));

    await dao.update(id, {'dueDay': 20});

    final all = await dao.getAll();
    expect(all.first['dueDay'], 20);
  });

  test('delete removes the row', () async {
    final id = await dao.insert(data());

    final deleted = await dao.delete(id);

    expect(deleted, 1);
    expect(await dao.getAll(), isEmpty);
  });
}
