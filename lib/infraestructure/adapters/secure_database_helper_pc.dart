//import 'package:sqflite_sqlcipher/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/infraestructure/adapters/silenti_schema.dart';

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
        await SilentiSchema.createAll(db);
        await SilentiSchema.seedInitialData(db);
      },
    );
  }
}
