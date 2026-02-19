import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khazina/features/transactions/presentation/cubit/transaction_cubit.dart';
import 'package:khazina/features/transactions/presentation/cubit/transaction_state.dart';
import 'package:khazina/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:khazina/core/constants/enums.dart';
import 'package:khazina/core/constants/app_constants.dart';

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
              child: CircularProgressIndicator(
                color: AppConstants.kPrimaryColor,
              ),
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
                    color: AppConstants.kSurfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          (isPayment
                                  ? AppConstants.kSecondaryColor
                                  : AppConstants.kErrorColor)
                              .withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                                    ? AppConstants.kSecondaryColor
                                    : AppConstants.kErrorColor)
                                .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPayment ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isPayment
                            ? AppConstants.kSecondaryColor
                            : AppConstants.kErrorColor,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      transaction.amount.toStringAsFixed(2),
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
                        color:
                            (transaction.partyType == PartyType.internal
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFFF59E0B))
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        transaction.partyType == PartyType.supplier
                            ? "مورد"
                            : transaction.partyType == PartyType.customer
                            ? "عميل"
                            : "خزينة",
                        style: TextStyle(
                          color: AppConstants.kPrimaryColor,
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
