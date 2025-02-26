//import 'package:sqflite_sqlcipher/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SecureDatabaseHelperPC {
  static final SecureDatabaseHelperPC _instance =
      SecureDatabaseHelperPC._internal();
  static Database? _database;

  factory SecureDatabaseHelperPC() => _instance;

  SecureDatabaseHelperPC._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    String path =
        join(directory.path, 'ssilenti.db'); //TODO add a user base DB name

    if (kDebugMode) {
      print("DB path: $path");
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(_createUsersTable);
        await db.execute(_initUsers);
        await db.execute(_createTransactionsTable);
        await db.execute(_initTransactions);
        await db.execute(_createBudgetCategoriesTable);
        await db.execute(_initBudgetCategories);
        await db.execute(_createNotificationsTable);
        await db.execute(_initNotifications);
        await db.execute(_createFinancialAssetsTable);
        await db.execute(_initAccounts);
        await db.execute(_createProfitsTable);
        await db.execute(_initProfits);
      },
    );
  }

  static const String _createTransactionsTable = '''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      description TEXT,
      category TEXT,
      type TEXT CHECK(type IN ('income', 'spent')) NOT NULL
    )
  ''';

  static const String _createBudgetCategoriesTable = '''
    CREATE TABLE budgetcategories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type 
      source TEXT NOT NULL,
      amount REAL NOT NULL,
      frequency TEXT CHECK(frecuency IN ('daily', 'weekly', 'monthly', 'anual','once')) NOT NULL,
      firstTime TEXT NOT NULL
    )
  ''';

  static const String _createNotificationsTable = '''
    CREATE TABLE notifications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      message TEXT NOT NULL,
      date TEXT NOT NULL,
      status TEXT CHECK(estado IN ('pending', 'send', 'read')) NOT NULL,
      transaction_id INTEGER,
      FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
    )
  ''';
  static const String _createFinancialAssetsTable = '''
    CREATE TABLE accounts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      account_balance REAL NOT NULL,
      included_on_balance INTEGER NOT NULL,
      interes_rate REAL,
      payment_frequency TEXT
    )
  ''';
  static const String _createProfitsTable = '''
    CREATE TABLE profits (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      account_id INTEGER NOT NULL,
      date TEXT NOT NULL,
      amount REAL NOT NULL,
      FOREIGN KEY (account_id) REFERENCES accounts(id)
    )
  ''';
  static const String _createUsersTable = '''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      mode INTEGER NOT NULL,
      group INTEGER NOT NULL,
      name TEXT NOT NULL,
      email TEXT NOT NULL,
      password TEXT NOT NULL
    )
  ''';
  static const String _initUsers = '''
    INSERT INTO users (mode, group, name, email, password)
    VALUES (1, 1, 'admin', '
  ''';
  static const String _initAccounts = '''
    INSERT INTO accounts (name, account_balance, included_on_balance, interes_rate, payment_frequency)
    VALUES ('Cash', 0, 1, 0, 'once')
  ''';
  static const String _initBudgetCategories = '''
    INSERT INTO budgetcategories (source, amount, frequency, firstTime)
    VALUES ('Salary', 0, 'monthly', '2021-01-01')
  ''';
  static const String _initTransactions = '''
    INSERT INTO transactions (amount, date, description, category, type)
    VALUES (0, '2021-01-01', 'Initial balance', 'Salary', 'income')
  ''';
  static const String _initProfits = '''
    INSERT INTO profits (account_id, date, amount)
    VALUES (1, '2021-01-01', 0)
  ''';
  static const String _initNotifications = '''
    INSERT INTO notifications (message, date, status, transaction_id)
    VALUES ('Initial balance', '2021-01-01', 'send', 1)
  ''';
}
