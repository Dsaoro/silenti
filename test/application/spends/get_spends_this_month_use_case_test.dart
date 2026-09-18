import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/application/spends/get_spends_this_month_use_case.dart';
import 'package:silenti/infraestructure/storage/operation_dao.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late GetSpendsThisMonthUseCase useCase;

  setUp(() async {
    db = await openTestDatabase();
    useCase = GetSpendsThisMonthUseCase(
      dao: OperationDAO(databaseProvider: () async => db),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('a month with no operations is a successful 0.0, not an error', () async {
    // BUSINESS_LOGIC_AUDIT.md #3.6 — this used to throw a StateError
    // internally (GROUP BY returning zero rows) and report as an error.
    final result = await useCase.execute();

    expect(result.status, isTrue);
    expect(result.model, 0.0);
  });

  test('sums only spent operations from the current month', () async {
    final now = DateTime.now();
    await db.insert('Operations', {
      'financialAsset': 1,
      'amount': 300.0,
      'date': DateTime(now.year, now.month, 5).toIso8601String(),
      'description': 'Mercado',
      'category': 1,
      'type': 'spent',
    });
    await db.insert('Operations', {
      'financialAsset': 1,
      'amount': 200.0,
      'date': DateTime(now.year, now.month, 10).toIso8601String(),
      'description': 'Ropa',
      'category': 1,
      'type': 'spent',
    });
    // A different month must not be counted.
    await db.insert('Operations', {
      'financialAsset': 1,
      'amount': 999.0,
      'date': DateTime(now.year, now.month == 1 ? 12 : now.month - 1, 5)
          .toIso8601String(),
      'description': 'Mes pasado',
      'category': 1,
      'type': 'spent',
    });

    final result = await useCase.execute();

    expect(result.status, isTrue);
    expect(result.model, 500.0);
  });
}
