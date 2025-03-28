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
    String path = join(
      directory.path,
      'ssilenti.db',
    ); //TODO add a user base DB name

    if (kDebugMode) {
      print("DB path: $path");
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(_createUsersTable);
        await db.execute(_createFinancialAssetsTable);
        await db.execute(_createProfitsTable);
        await db.execute(_createBudgetCategoriesTable);
        await db.execute(_createSubCategories);
        await db.execute(_createOperationsTable);
        await db.execute(_createNotificationsTable);

        await db.execute(_initUsers);
        await db.execute(_initFinancialAssets);
        await db.execute(_initProfits);
        await db.execute(_initBudgetCategories);
        await db.execute(_initOperations);
        await db.execute(_initNotifications);
      },
    );
  }

  static const String _createUsersTable = '''
  CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mode INTEGER NOT NULL,
    mode_group INTEGER NOT NULL,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    password TEXT NOT NULL
  )
  ''';
  static const String _initUsers = '''
  INSERT INTO users (mode, mode_group, name, email, password)
    VALUES (1, 1, 'user', '','')
  ''';

  static const String _createFinancialAssetsTable = '''
  CREATE TABLE financial_assets(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    balance REAL NOT NULL,
    included INTEGER NOT NULL,
    interestRate REAL,
    frequency TEXT CHECK(frequency IN ('daily', 'weekly', 'semi-monthly', 'monthly', 'anual', 'once')) NOT NULL
  )
  ''';
  static const String _initFinancialAssets = '''
  INSERT INTO financial_assets (name, balance, included, interestRate, frequency)
    VALUES ('Efectivo', 5000, 1, 0, 'once')
  ''';

  static const String _createProfitsTable = '''
  CREATE TABLE profits (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    financialAsset INTEGER NOT NULL,
    date TEXT NOT NULL,
    amount REAL NOT NULL,
    FOREIGN KEY (financialAsset) REFERENCES financial_assets(id) 
  )
  ''';
  static const String _initProfits = '''
  INSERT INTO profits (financialAsset, date, amount)  
    VALUES (0, '2021-01-01', 0)
  ''';

  static const String _createBudgetCategoriesTable = '''
  CREATE TABLE budget_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT CHECK(type IN ('income', 'spent') NOT NULL),
    name TEXT NOT NULL,
    amount REAL NOT NULL,
    frequency TEXT CHECK(frequency IN ('daily', 'weekly', 'semi-monthly', 'monthly', 'anual', 'once')) NOT NULL,
    firstTime TEXT NOT NULL
  )
  ''';
  static const String _initBudgetCategories = '''
  INSERT INTO budget_categories (type, name, amount, frequency, firstTime)
    VALUES ('spent','various', 0, 'monthly', '2025-03-01')
  ''';

  static const String _createSubCategories = '''
  CREATE TABLE spend_sub_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category INTEGER NOT NULL,
    name TEXT NOT NULL,
    amount REAL NOT NULL,
    FOREIGN KEY (category) REFERENCES budget_categories(id)
  )
  ''';

  static const String _createOperationsTable = '''
  CREATE TABLE operations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    financialAsset INTEGER NOT NULL,
    amount REAL NOT NULL,
    date TEXT NOT NULL,
    description TEXT,
    category INTEGER NOT NULL,
    type TEXT CHECK(type IN ('income', 'spent')) NOT NULL,
    FOREIGN KEY (financialAsset) REFERENCES financial_assets(id)
    FOREIGN KEY (category) REFERENCES budget_categories(id)
  )
  ''';

  static const String _initOperations = '''
  INSERT INTO Operations (financialAsset, amount, date, description, category, type)
    VALUES (0, 0, '2021-01-01', 'Initial balance', 1, 'income')
  ''';
  static const String _createNotificationsTable = '''
  CREATE TABLE notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    message TEXT NOT NULL,
    date TEXT NOT NULL,
    status TEXT CHECK(status IN ('pending', 'send', 'read')) NOT NULL,
    Operation_id INTEGER,
    FOREIGN KEY (Operation_id) REFERENCES Operations(id)
  )
  ''';

  static const String _initNotifications = '''
  INSERT INTO notifications (message, date, status, Operation_id)
    VALUES ('Initial balance', '2021-01-01', 'send', 1)
  ''';
}
