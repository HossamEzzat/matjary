import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/entities/transaction.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository repository;

  TransactionCubit(this.repository) : super(TransactionInitial());

  Future<void> loadTransactions([String? partyId]) async {
    emit(TransactionLoading());
    try {
      final transactions = partyId != null
          ? await repository.getTransactionsByParty(partyId)
          : await repository.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await repository.addTransaction(transaction);
      // Reload is handled by the caller or we reload here
      loadTransactions(transaction.partyId);
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    try {
      await repository.deleteTransaction(transaction.id);
      loadTransactions(transaction.partyId);
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
