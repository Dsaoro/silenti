import 'package:flutter/foundation.dart';
import 'package:silenti/core/models/balance_history.dart';
import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';
import 'package:silenti/infraestructure/storage/balance_history_dao.dart';

class FinancialAssetsDao {
  Future<int> insertAccount(Map<String, dynamic> data) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.insert('financial_assets', data);
  }

  Future<int> deleteAccountById(int id) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db
        .delete('financial_assets', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAccounts() async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query('financial_assets');
  }

  Future<List<Map<String, dynamic>>> getAccountById(int financialAsset) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.query(
      'financial_assets',
      where: 'id = ?',
      whereArgs: [financialAsset],
    );
  }

  Future<int> updateAccountById(
      int financialAsset, Map<String, dynamic> data) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.update(
      'financial_assets',
      data,
      where: 'id = ?',
      whereArgs: [financialAsset],
    );
  }

  Future<List<Map<String, Object?>>> getAccountBalance() async {
    final db = await SecureDatabaseHelperPC().database;
    List<Map<String, Object?>> result = await db.rawQuery(
      'SELECT SUM(balance) as balance FROM financial_assets WHERE included = 1',
    );
    return result;
  }

  Future<List<Map<String, Object?>>> deposit(
      {required int financialAsset,
      required double amount,
      int? operationId}) async {
    final db = await SecureDatabaseHelperPC().database;
    var check = await db.query(
      'financial_assets',
      where: 'id = ?',
      whereArgs: [financialAsset],
    );
    if (check.isEmpty) {
      //return error
      if (kDebugMode) {
        print("financial asset not found $financialAsset");
      }
      return [];
    }

    // Actualizar balance
    var result =
        await db.rawQuery('''UPDATE financial_assets SET balance = balance +
    $amount WHERE id=$financialAsset;''');

    // Obtener el nuevo balance
    var updatedAsset = await db.query(
      'financial_assets',
      where: 'id = ?',
      whereArgs: [financialAsset],
    );

    if (updatedAsset.isNotEmpty) {
      double newBalance = updatedAsset.first['balance'] as double;

      // Registrar en el historial
      BalanceHistoryDAO balanceHistoryDAO = BalanceHistoryDAO();
      await balanceHistoryDAO.insertBalanceHistory(
        BalanceHistory(
          id: 0, // Se auto-incrementa
          financialAssetId: financialAsset,
          balance: newBalance,
          date: DateTime.now(),
          operationId: operationId,
        ),
      );
    }

    return result;
  }

  Future<List<Map<String, Object?>>> withdraw(
      {required int financialAsset,
      required double amount,
      int? operationId}) async {
    final db = await SecureDatabaseHelperPC().database;
    var check = await db.query(
      'financial_assets',
      where: 'id = ?',
      whereArgs: [financialAsset],
    );
    if (check.isEmpty) {
      //return error
      if (kDebugMode) {
        print("financial asset not found $financialAsset");
      }
      return [];
    }

    // Actualizar balance
    var result =
        await db.rawQuery('''UPDATE financial_assets SET balance = balance -
    $amount WHERE id=$financialAsset;''');

    // Obtener el nuevo balance
    var updatedAsset = await db.query(
      'financial_assets',
      where: 'id = ?',
      whereArgs: [financialAsset],
    );

    if (updatedAsset.isNotEmpty) {
      double newBalance = updatedAsset.first['balance'] as double;

      // Registrar en el historial
      BalanceHistoryDAO balanceHistoryDAO = BalanceHistoryDAO();
      await balanceHistoryDAO.insertBalanceHistory(
        BalanceHistory(
          id: 0, // Se auto-incrementa
          financialAssetId: financialAsset,
          balance: newBalance,
          date: DateTime.now(),
          operationId: operationId,
        ),
      );
    }

    return result;
  }
}
