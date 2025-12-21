import 'package:matjary/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:matjary/features/transactions/data/models/transaction_model.dart';
import 'package:matjary/features/transactions/domain/entities/transaction.dart';
import 'package:matjary/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addTransaction(Transaction transaction) async {
    await localDataSource.addTransaction(
      TransactionModel.fromEntity(transaction),
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await localDataSource.deleteTransaction(id);
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final models = await localDataSource.getAllTransactions(); // Sorted?
    // Sort by date descending
    final sorted = models.toList()..sort((a, b) => b.date.compareTo(a.date));
    return sorted.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByParty(String partyId) async {
    final models = await localDataSource.getTransactionsByParty(partyId);
    final sorted = models.toList()..sort((a, b) => b.date.compareTo(a.date));
    return sorted.map((e) => e.toEntity()).toList();
  }
}
