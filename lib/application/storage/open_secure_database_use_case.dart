// import 'package:silenti/infraestructure/adapters/secure_database_helper.dart';
import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// import 'package:sqflite_sqlcipher/sqflite.dart'
class OpenSecureDatabaseUseCase {
  // final SecureDatabaseHelper _dbHelper = SecureDatabaseHelper();
  final SecureDatabaseHelperPC _dbHelper = SecureDatabaseHelperPC();

  Future<Database> execute({required String password}) async {
    try {
      Database db = await _dbHelper.database;
      return db;
    } catch (e) {
      throw Exception("Error al abrir la base de datos: $e");
    }
  }
}
