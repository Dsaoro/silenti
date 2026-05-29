import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class NotificacionDAO {
  Future<int> insertNotificacion(Map<String, dynamic> notificacion) async {
    final db = await SecureDatabaseHelperPC().database;
    return await db.insert('notifications', notificacion);
  }

  Future<List<Map<String, dynamic>>> getNotificacionesPendientes() async {
    final db = await SecureDatabaseHelperPC().database;
    return await db
        .query('notifications', where: 'status = ?', whereArgs: ['pending']);
  }
}
