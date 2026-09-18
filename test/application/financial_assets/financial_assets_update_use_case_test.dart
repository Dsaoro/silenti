import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/application/financial_assets/financial_assets_update_use_case.dart';
import 'package:silenti/core/models/financial_asset.dart';
import 'package:silenti/infraestructure/storage/financial_assets_dao.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late FinancialAssetsUpdateUseCase useCase;

  setUp(() async {
    db = await openTestDatabase();
    useCase = FinancialAssetsUpdateUseCase(
      dao: FinancialAssetsDao(databaseProvider: () async => db),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('editing an existing asset persists the new name and balance', () async {
    final id = await db.insert('financial_assets', {
      'type': 'BANK',
      'name': 'Nombre viejo',
      'balance': 1000.0,
      'included': 1,
      'frequency': 'once',
      'interestRate': 0.0,
    });

    final result = await useCase.execute(BankAccount(
      id: id,
      name: 'Nombre nuevo',
      includedOnBalance: 1,
      frequency: Frequency.monthly,
      balance: 2500,
      interestRate: 0.05,
    ));

    expect(result.status, isTrue);

    final rows = await db.query('financial_assets', where: 'id = ?', whereArgs: [id]);
    expect(rows.first['name'], 'Nombre nuevo');
    expect(rows.first['balance'], 2500.0);
    expect(rows.first['interestRate'], 0.05);
  });

  test('editing a non-existent asset reports failure', () async {
    final result = await useCase.execute(BankAccount(
      id: 999999,
      name: 'No existe',
      includedOnBalance: 1,
      frequency: Frequency.once,
      balance: 0,
      interestRate: 0,
    ));

    expect(result.status, isFalse);
  });
}
