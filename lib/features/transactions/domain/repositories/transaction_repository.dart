import 'package:matjary/features/transactions/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAllTransactions();
  Future<List<Transaction>> getTransactionsByParty(String partyId);
  Future<void> addTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  // Optional: updateTransaction, usually transactions are immutable logs, but editing might be requested.
  // For now, let's keep it simple: add and delete (or void).
}
