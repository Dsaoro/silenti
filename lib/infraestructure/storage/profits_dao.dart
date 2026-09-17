import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/infraestructure/adapters/secure_database_helper_pc.dart';

class ProfitsDAO {
  final Future<Database> Function() _databaseProvider;
  ProfitsDAO({Future<Database> Function()? databaseProvider})
      : _databaseProvider =
            databaseProvider ?? (() => SecureDatabaseHelperPC().database);

  Future<int> insertProfit(Map<String, dynamic> data) async {
    final db = await _databaseProvider();
    return await db.insert('profits', data);
  }

  Future<List<Map<String, dynamic>>> getprofits(int financialAsset) async {
    final db = await _databaseProvider();
    return await db.query(
      'profits',
      where: 'financialAsset = ?',
      whereArgs: [financialAsset],
    );
  }
}
