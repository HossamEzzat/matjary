import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khazina/features/suppliers/domain/repositories/supplier_repository.dart';
import 'package:khazina/features/customers/domain/repositories/customer_repository.dart';
import 'package:khazina/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:khazina/core/constants/enums.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final SupplierRepository supplierRepository;
  final CustomerRepository customerRepository;
  final TransactionRepository transactionRepository;

  DashboardCubit({
    required this.supplierRepository,
    required this.customerRepository,
    required this.transactionRepository,
  }) : super(DashboardInitial());

  Future<void> loadDashboardData() async {
    emit(DashboardLoading());
    try {
      final suppliers = await supplierRepository.getSuppliers();
      final customers = await customerRepository.getCustomers();
      final transactions = await transactionRepository.getAllTransactions();

      // Calculation:
      // Payables: Sum of supplier.balance.
      final totalPayables = suppliers.fold(0.0, (sum, s) => sum + s.balance);

      // Receivables: Sum of customer.balance.
      final totalReceivables = customers.fold(0.0, (sum, c) => sum + c.balance);

      // Treasury calculation:
      // Customer Payments (Money In) - Supplier Payments (Money Out)
      double totalTreasury = 0.0;
      for (final tx in transactions) {
        if (tx.type == TransactionType.payment) {
          if (tx.partyType == PartyType.customer) {
            totalTreasury += tx.amount;
          } else if (tx.partyType == PartyType.supplier) {
            totalTreasury -= tx.amount;
          } else if (tx.partyType == PartyType.internal) {
            totalTreasury +=
                tx.amount; // Positive for deposit, negative for withdrawal
          }
        }
      }

      emit(
        DashboardLoaded(
          totalPayables: totalPayables,
          totalReceivables: totalReceivables,
          totalTreasury: totalTreasury,
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
