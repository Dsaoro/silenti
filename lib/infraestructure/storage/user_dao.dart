import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class UserDAO {
  final Future<Database> Function() _databaseProvider;
  UserDAO({Future<Database> Function()? databaseProvider})
      : _databaseProvider =
            databaseProvider ?? (() => SecureDatabaseHelperPC().database);

  Future<Map<String, dynamic>?> getUser() async {
    final db = await _databaseProvider();
    final List<Map<String, dynamic>> maps = await db.query('users', limit: 1);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> registerUser(String name, String email, String password) async {
    final db = await _databaseProvider();
    return await db.update(
      'users',
      {
        'name': name,
        'email': email,
        'password': password,
      },
      where: 'id = ?',
      whereArgs: [1], // Default user has ID 1
    );
  }
}
