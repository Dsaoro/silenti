import 'package:silenti/core/models/transaction.dart';

abstract class TransactionRepository {
  Future<void> addTransaction(Transaction transaction);
  Future<List<Transaction>> getTransactions();
  Future<void> deleteTransaction(int id);
}
