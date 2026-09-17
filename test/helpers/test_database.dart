import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:silenti/infraestructure/adapters/silenti_schema.dart';

/// Opens a fresh in-memory SQLite database with the exact same schema
/// Silenti uses in production (see [SilentiSchema]), for DAO/use-case tests
/// that need real SQL behavior instead of a mocked DAO.
///
/// Call [sqfliteFfiInit] once per test process (safe to call repeatedly) and
/// always `await db.close()` in `tearDown` — `:memory:` databases opened
/// through `sqflite_common_ffi` are cached by path, so leaving one open can
/// leak state into the next test that asks for a fresh one.
Future<Database> openTestDatabase({bool seed = false}) async {
  sqfliteFfiInit();
  return databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      singleInstance: false,
      onCreate: (db, version) async {
        await SilentiSchema.createAll(db);
        if (seed) {
          await SilentiSchema.seedInitialData(db);
        }
      },
    ),
  );
}
