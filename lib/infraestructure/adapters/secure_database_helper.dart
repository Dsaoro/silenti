// import 'package:sqflite_sqlcipher/sqflite.dart';
// // ignore: depend_on_referenced_packages
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

// class SecureDatabaseHelper {
//   static final SecureDatabaseHelper _instance =
//       SecureDatabaseHelper._internal();
//   static Database? _database;

//   factory SecureDatabaseHelper() => _instance;

//   SecureDatabaseHelper._internal();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB();
//     return _database!;
//   }

//   Future<Database> _initDB({String? password}) async {
//     final directory = await getApplicationDocumentsDirectory();
//     String path =
//         join(directory.path, 'ssilenti.db'); //TODO add a user base DB name

//     return await openDatabase(
//       path,
//       password: password,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute(_createUsersTable);
//         await db.execute(_initUsers);
//         await db.execute(_createOperationsTable);
//         await db.execute(_initOperations);
//         await db.execute(_createBudgetCategoriesTable);
//         await db.execute(_initBudgetCategories);
//         await db.execute(_createNotificationsTable);
//         await db.execute(_initNotifications);
//         await db.execute(_createFinancialAssetsTable);
//         await db.execute(_initAccounts);
//         await db.execute(_createProfitsTable);
//         await db.execute(_initProfits);
//       },
//     );
//   }

//   static const String _createOperationsTable = '''
//     CREATE TABLE Operations (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       amount REAL NOT NULL,
//       date TEXT NOT NULL,
//       description TEXT,
//       category TEXT,
//       type TEXT CHECK(type IN ('income', 'spent')) NOT NULL
//     )
//   ''';

//   static const String _createBudgetCategoriesTable = '''
//     CREATE TABLE budgetcategories (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       type
//       source TEXT NOT NULL,
//       amount REAL NOT NULL,
//       frequency TEXT CHECK(frecuency IN ('daily', 'weekly', 'monthly', 'anual','once')) NOT NULL,
//       firstTime TEXT NOT NULL
//     )
//   ''';

//   static const String _createNotificationsTable = '''
//     CREATE TABLE notifications (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       message TEXT NOT NULL,
//       date TEXT NOT NULL,
//       status TEXT CHECK(estado IN ('pending', 'send', 'read')) NOT NULL,
//       Operation_id INTEGER,
//       FOREIGN KEY (Operation_id) REFERENCES Operations(id) ON DELETE CASCADE
//     )
//   ''';
//   static const String _createFinancialAssetsTable = '''
//     CREATE TABLE accounts(
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       name TEXT NOT NULL,
//       balance REAL NOT NULL,
//       included INTEGER NOT NULL,
//       interes_rate REAL,
//       payment_frequency TEXT
//     )
//   ''';
//   static const String _createProfitsTable = '''
//     CREATE TABLE profits (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       financialAsset INTEGER NOT NULL,
//       date TEXT NOT NULL,
//       amount REAL NOT NULL,
//       FOREIGN KEY (financialAsset) REFERENCES accounts(id)
//     )
//   ''';
//   static const String _createUsersTable = '''
//     CREATE TABLE users (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       mode INTEGER NOT NULL,
//       group INTEGER NOT NULL,
//       name TEXT NOT NULL,
//       email TEXT NOT NULL,
//       password TEXT NOT NULL
//     )
//   ''';
//   static const String _initUsers = '''
//     INSERT INTO users (mode, group, name, email, password)
//     VALUES (1, 1, 'admin', '
//   ''';
//   static const String _initAccounts = '''
//     INSERT INTO accounts (name, balance, included, interes_rate, payment_frequency)
//     VALUES ('Cash', 0, 1, 0, 'once')
//   ''';
//   static const String _initBudgetCategories = '''
//     INSERT INTO budgetcategories (source, amount, frequency, firstTime)
//     VALUES ('Salary', 0, 'monthly', CURRENT_TIMESTAMP)
//   ''';
//   static const String _initOperations = '''
//     INSERT INTO Operations (amount, date, description, category, type)
//     VALUES (0, CURRENT_TIMESTAMP, 'Initial balance', 'Salary', 'income')
//   ''';
//   static const String _initProfits = '''
//     INSERT INTO profits (financialAsset, date, amount)
//     VALUES (1, CURRENT_TIMESTAMP, 0)
//   ''';
//   static const String _initNotifications = '''
//     INSERT INTO notifications (message, date, status, Operation_id)
//     VALUES ('Initial balance', CURRENT_TIMESTAMP, 'send', 1)
//   ''';
// }
