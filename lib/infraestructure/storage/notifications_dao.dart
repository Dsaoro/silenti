import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class NotificacionDAO {
  final Future<Database> Function() _databaseProvider;
  NotificacionDAO({Future<Database> Function()? databaseProvider})
      : _databaseProvider =
            databaseProvider ?? (() => SecureDatabaseHelperPC().database);

  Future<int> insertNotificacion(Map<String, dynamic> notificacion) async {
    final db = await _databaseProvider();
    return await db.insert('notifications', notificacion);
  }

  Future<List<Map<String, dynamic>>> getNotificacionesPendientes() async {
    final db = await _databaseProvider();
    return await db
        .query('notifications', where: 'status = ?', whereArgs: ['pending']);
  }
}
