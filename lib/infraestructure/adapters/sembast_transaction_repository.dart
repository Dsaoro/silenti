import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:silenti/infraestructure/adapters/encrytion_helper.dart';

class SembastTransactionRepository {
  static final SembastTransactionRepository _instance =
      SembastTransactionRepository._internal();
  factory SembastTransactionRepository() => _instance;

  SembastTransactionRepository._internal();

  Database? _db;
  final store = intMapStoreFactory.store('transactions');

  Future<Database> _openDatabase() async {
    if (_db != null) return _db!;

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/silenti.db';

    // Obtener clave de cifrado
    final encryptionHelper = EncryptionHelper();
    final key = await encryptionHelper.getEncryptionKey();

    // final codec = getEncryptSembastCodec(password: key);

    _db = await databaseFactoryIo.openDatabase(dbPath);
    return _db!;
  }

  Future<void> addTransaction(Map<String, dynamic> transaction) async {
    final db = await _openDatabase();
    await store.add(db, transaction);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await _openDatabase();
    final records = await store.find(db);
    return records.map((e) => e.value).toList();
  }
}
