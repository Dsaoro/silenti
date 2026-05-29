import 'package:flutter/foundation.dart';
import 'package:silenti/application/shared/base_use_case.dart';
import 'package:silenti/application/shared/handle_result.dart';
import 'package:silenti/core/models/balance_history.dart';
import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';
import 'package:silenti/infraestructure/storage/balance_history_dao.dart';
import 'package:silenti/infraestructure/storage/financial_assets_dao.dart';

class MigrateDatabaseUseCase extends BaseUseCase {
  MigrateDatabaseUseCase() : super("MigrateDatabase");

  Future<HandleResult<bool>> execute() async {
    HandleResult<bool> result = HandleResult<bool>();

    try {
      final db = await SecureDatabaseHelperPC().database;

      // Verificar si la tabla balance_history ya existe
      var tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='balance_history';");

      if (tables.isEmpty) {
        // Crear la tabla balance_history
        await db.execute('''
          CREATE TABLE balance_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            financialAssetId INTEGER NOT NULL,
            balance REAL NOT NULL,
            date TEXT NOT NULL,
            operationId INTEGER,
            FOREIGN KEY (financialAssetId) REFERENCES financial_assets(id),
            FOREIGN KEY (operationId) REFERENCES operations(id)
          )
        ''');

        if (kDebugMode) {
          print("Created balance_history table");
        }

        // Crear historial inicial para todos los activos financieros existentes
        await _createInitialBalanceHistory();
      }

      result.setData(true);
    } catch (e) {
      result.setError("Error migrating database: ${e.toString()}");
      if (kDebugMode) {
        print("Migration error: $e");
      }
    }

    return result;
  }

  Future<void> _createInitialBalanceHistory() async {
    try {
      FinancialAssetsDao assetsDao = FinancialAssetsDao();
      BalanceHistoryDAO historyDao = BalanceHistoryDAO();

      // Obtener todos los activos financieros
      List<Map<String, dynamic>> assets = await assetsDao.getAccounts();

      for (var assetMap in assets) {
        int assetId = assetMap['id'];
        double currentBalance = assetMap['balance']?.toDouble() ?? 0.0;

        // Crear entrada inicial en el historial con la fecha actual
        await historyDao.insertBalanceHistory(
          BalanceHistory(
            id: 0, // Se auto-incrementa
            financialAssetId: assetId,
            balance: currentBalance,
            date: DateTime.now(),
            operationId: null, // Sin operación asociada para el balance inicial
          ),
        );

        if (kDebugMode) {
          print(
              "Created initial balance history for asset $assetId with balance $currentBalance");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error creating initial balance history: $e");
      }
      rethrow;
    }
  }
}
