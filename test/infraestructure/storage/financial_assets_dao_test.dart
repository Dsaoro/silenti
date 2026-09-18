import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/core/models/operation.dart';
import 'package:silenti/infraestructure/storage/financial_assets_dao.dart';

import '../../helpers/test_database.dart';

void main() {
  late Database db;
  late FinancialAssetsDao dao;

  setUp(() async {
    db = await openTestDatabase();
    dao = FinancialAssetsDao(databaseProvider: () async => db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> seedAccount({double balance = 1000}) {
    return db.insert('financial_assets', {
      'type': 'BANK',
      'name': 'Cuenta de prueba',
      'balance': balance,
      'included': 1,
      'frequency': 'once',
      'interestRate': 0.0,
    });
  }

  Map<String, dynamic> operationData({
    required int financialAsset,
    double amount = 500,
    String type = Operation.income,
    int category = 1,
  }) {
    return Operation(
      id: 0,
      financialAsset: financialAsset,
      amount: amount,
      date: DateTime(2026, 1, 1),
      description: 'test',
      category: category,
      type: type,
    ).toMap();
  }

  group('FinancialAssetsDao.applyOperation (deposit)', () {
    test(
        'atomically inserts the operation, updates the balance and records balance_history',
        () async {
      final assetId = await seedAccount(balance: 1000);

      final applied = await dao.applyOperation(
        operationData: operationData(financialAsset: assetId, amount: 500),
        financialAsset: assetId,
        amount: 500,
        isDeposit: true,
      );

      expect(applied, isNotNull);
      expect(applied!.newBalance, 1500.0);

      final updated = await dao.getAccountById(assetId);
      expect(updated.first['balance'], 1500.0);

      final operations = await db.query('Operations');
      expect(operations, hasLength(1));
      expect(operations.first['id'], applied.operationId);

      final history = await db.query('balance_history',
          where: 'financialAssetId = ?', whereArgs: [assetId]);
      expect(history, hasLength(1));
      expect(history.first['balance'], 1500.0);
      expect(history.first['operationId'], applied.operationId);
    });

    test(
        'returns null and writes nothing (no operation, no balance change, no history) '
        'when the asset does not exist', () async {
      final applied = await dao.applyOperation(
        operationData: operationData(financialAsset: 999999, amount: 500),
        financialAsset: 999999,
        amount: 500,
        isDeposit: true,
      );

      expect(applied, isNull);
      expect(await db.query('Operations'), isEmpty);
      expect(await db.query('balance_history'), isEmpty);
    });
  });

  group('FinancialAssetsDao.applyOperation (withdraw)', () {
    test('decreases the balance and records balance_history', () async {
      final assetId = await seedAccount(balance: 1000);

      final applied = await dao.applyOperation(
        operationData: operationData(
            financialAsset: assetId, amount: 300, type: Operation.expense),
        financialAsset: assetId,
        amount: 300,
        isDeposit: false,
      );

      expect(applied!.newBalance, 700.0);
      final history = await db.query('balance_history');
      expect(history, hasLength(1));
    });

    test('does not stop the balance from going negative (no overdraft guard today)',
        () async {
      final assetId = await seedAccount(balance: 100);

      final applied = await dao.applyOperation(
        operationData: operationData(
            financialAsset: assetId, amount: 500, type: Operation.expense),
        financialAsset: assetId,
        amount: 500,
        isDeposit: false,
      );

      // BUSINESS_LOGIC_AUDIT.md #3.4: documents current behavior, not a
      // desired one — revisit this test if/when an overdraft guard is added.
      expect(applied!.newBalance, -400.0);
    });
  });

  group('FinancialAssetsDao CRUD', () {
    test('insertAccount + getAccounts round-trip', () async {
      await seedAccount();

      final accounts = await dao.getAccounts();

      expect(accounts, hasLength(1));
      expect(accounts.first['name'], 'Cuenta de prueba');
    });

    test('deleteAccountById removes the row', () async {
      final assetId = await seedAccount();

      final deleted = await dao.deleteAccountById(assetId);

      expect(deleted, 1);
      expect(await dao.getAccounts(), isEmpty);
    });

    test('getAccountBalance sums only accounts included in the balance', () async {
      await seedAccount(balance: 1000);
      await db.insert('financial_assets', {
        'type': 'BANK',
        'name': 'Excluida',
        'balance': 5000,
        'included': 0,
        'frequency': 'once',
        'interestRate': 0.0,
      });

      final result = await dao.getAccountBalance();

      expect(result.first['balance'], 1000.0);
    });
  });
}
