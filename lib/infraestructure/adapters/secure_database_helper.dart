import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class SecureDatabaseHelper {
  static final SecureDatabaseHelper _instance =
      SecureDatabaseHelper._internal();
  static Database? _database;

  factory SecureDatabaseHelper() => _instance;

  SecureDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'ssilenti.db');

    return await openDatabase(
      path,
      password:
          'TuClaveSegura123!', // Asegúrate de almacenar esto de forma segura
      version: 1,
      onCreate: (db, version) async {
        await db.execute(_createTransactionsTable);
        await db.execute(_createBudgetCategoriesTable);
        await db.execute(_createNotificationsTable);
      },
    );
  }

  static const String _createTransactionsTable = '''
    CREATE TABLE transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      ammount REAL NOT NULL,
      date TEXT NOT NULL,
      description TEXT,
      category TEXT,
      type TEXT CHECK(tipo IN ('income', 'spent')) NOT NULL
    )
  ''';

  static const String _createBudgetCategoriesTable = '''
    CREATE TABLE budgetcategories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type 
      source TEXT NOT NULL,
      amount REAL NOT NULL,
      frequency TEXT CHECK(frecuencia IN ('daily', 'weekly', 'monthly', 'anual','once')) NOT NULL,
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
      FOREIGN KEY (transaccion_id) REFERENCES transactions (id) ON DELETE CASCADE
    )
  ''';
}
