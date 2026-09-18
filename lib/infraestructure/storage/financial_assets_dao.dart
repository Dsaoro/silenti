import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

/// Outcome of [FinancialAssetsDao.applyOperation]: the row id the
/// `Operations` insert got, and the asset's balance right after the
/// transaction committed.
class ApplyOperationResult {
  final int operationId;
  final double newBalance;
  const ApplyOperationResult(
      {required this.operationId, required this.newBalance});
}

class FinancialAssetsDao {
  final Future<Database> Function() _databaseProvider;
  FinancialAssetsDao({Future<Database> Function()? databaseProvider})
      : _databaseProvider =
            databaseProvider ?? (() => SecureDatabaseHelperPC().database);

  Future<int> insertAccount(Map<String, dynamic> data) async {
    final db = await _databaseProvider();
    return await db.insert('financial_assets', data);
  }

  Future<int> deleteAccountById(int id) async {
    final db = await _databaseProvider();
    return await db
        .delete('financial_assets', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAccounts() async {
    final db = await _databaseProvider();
    return await db.query('financial_assets');
  }

  Future<List<Map<String, dynamic>>> getAccountById(int financialAsset) async {
    final db = await _databaseProvider();
    return await db.query(
      'financial_assets',
      where: 'id = ?',
      whereArgs: [financialAsset],
    );
  }

  Future<int> updateAccountById(
      int financialAsset, Map<String, dynamic> data) async {
    final db = await _databaseProvider();
    return await db.update(
      'financial_assets',
      data,
      where: 'id = ?',
      whereArgs: [financialAsset],
    );
  }

  Future<List<Map<String, Object?>>> getAccountBalance() async {
    final db = await _databaseProvider();
    List<Map<String, Object?>> result = await db.rawQuery(
      'SELECT SUM(balance) as balance FROM financial_assets WHERE included = 1',
    );
    return result;
  }

  /// Atomically inserts [operationData] into `Operations`, adjusts
  /// [financialAsset]'s balance by +/- [amount], and records the resulting
  /// `balance_history` row — all inside a single DB transaction
  /// (BUSINESS_LOGIC_AUDIT.md #3.3: previously these were 3 independent
  /// writes, so a failure partway left orphaned rows).
  ///
  /// Returns `null`, writing nothing at all, if [financialAsset] doesn't
  /// exist. The caller MUST treat a `null` result as failure
  /// (BUSINESS_LOGIC_AUDIT.md #3.2: the old deposit()/withdraw() returned an
  /// empty list in this case, but every caller ignored it and reported
  /// success anyway).
  Future<ApplyOperationResult?> applyOperation({
    required Map<String, dynamic> operationData,
    required int financialAsset,
    required double amount,
    required bool isDeposit,
  }) async {
    final db = await _databaseProvider();
    return db.transaction<ApplyOperationResult?>((txn) async {
      final asset = await txn.query(
        'financial_assets',
        where: 'id = ?',
        whereArgs: [financialAsset],
      );
      if (asset.isEmpty) {
        return null;
      }

      final operationId = await txn.insert('Operations', operationData);

      final sign = isDeposit ? '+' : '-';
      await txn.rawUpdate(
        'UPDATE financial_assets SET balance = balance $sign ? WHERE id = ?',
        [amount, financialAsset],
      );

      final updated = await txn.query(
        'financial_assets',
        where: 'id = ?',
        whereArgs: [financialAsset],
      );
      final newBalance = (updated.first['balance'] as num).toDouble();

      await txn.insert('balance_history', {
        'financialAssetId': financialAsset,
        'balance': newBalance,
        'date': DateTime.now().toIso8601String(),
        'operationId': operationId,
      });

      return ApplyOperationResult(
        operationId: operationId,
        newBalance: newBalance,
      );
    });
  }
}
