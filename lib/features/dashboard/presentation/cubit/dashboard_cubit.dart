import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matjary/features/suppliers/domain/repositories/supplier_repository.dart';
import 'package:matjary/features/customers/domain/repositories/customer_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final SupplierRepository supplierRepository;
  final CustomerRepository customerRepository;

  DashboardCubit({
    required this.supplierRepository,
    required this.customerRepository,
  }) : super(DashboardInitial());

  Future<void> loadDashboardData() async {
    emit(DashboardLoading());
    try {
      final suppliers = await supplierRepository.getSuppliers();
      final customers = await customerRepository.getCustomers();

      // Calculation:
      // Payables: Sum of supplier.balance. (Assuming +ve means we owe them)
      final totalPayables = suppliers.fold(0.0, (sum, s) => sum + s.balance);

      // Receivables: Sum of customer.balance. (Assuming +ve means they owe us)
      final totalReceivables = customers.fold(0.0, (sum, c) => sum + c.balance);

      emit(
        DashboardLoaded(
          totalPayables: totalPayables,
          totalReceivables: totalReceivables,
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
