import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class UserDAO {
  Future<Map<String, dynamic>?> getUser() async {
    final db = await SecureDatabaseHelperPC().database;
    final List<Map<String, dynamic>> maps = await db.query('users', limit: 1);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> registerUser(String name, String email, String password) async {
    final db = await SecureDatabaseHelperPC().database;
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
