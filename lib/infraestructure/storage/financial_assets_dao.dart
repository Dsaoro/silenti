import 'package:flutter/foundation.dart';
import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

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
      {required int financialAsset, required double amount}) async {
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
    }
    return db.rawQuery('''UPDATE financial_assets SET balance = balance + 
    $amount WHERE id=$financialAsset;''');
  }

  Future<List<Map<String, Object?>>> withdraw(
      {required int financialAsset, required double amount}) async {
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
    }
    return db.rawQuery('''UPDATE financial_assets SET balance = balance - 
    $amount WHERE id=$financialAsset;''');
  }
}
