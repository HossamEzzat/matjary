import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khazina/features/transactions/presentation/cubit/transaction_cubit.dart';
import 'package:khazina/features/transactions/presentation/cubit/transaction_state.dart';
import 'package:khazina/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:khazina/core/constants/enums.dart';

class TransactionsListScreen extends StatelessWidget {
  const TransactionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TransactionCubit(context.read<TransactionRepository>())
            ..loadTransactions(),
      child: const TransactionsListView(),
    );
  }
}

class TransactionsListView extends StatelessWidget {
  const TransactionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل المعاملات')),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            );
          } else if (state is TransactionError) {
            return Center(child: Text('خطأ: ${state.message}'));
          } else if (state is TransactionLoaded) {
            if (state.transactions.isEmpty) {
              return const Center(
                child: Text(
                  "لا يوجد معاملات حتى الان",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                final transaction = state.transactions[index];
                final isPayment = transaction.type == TransactionType.payment;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B), // Slate Card
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          (isPayment
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444))
                              .withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            (isPayment
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444))
                                .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPayment ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isPayment
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        size: 24,
                      ),
                    ),
                    title: Text(
                      "${transaction.amount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        transaction.date.toString().substring(0, 10),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        transaction.partyType == PartyType.supplier
                            ? "مورد"
                            : "عميل",
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
