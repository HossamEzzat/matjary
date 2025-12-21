import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/entities/customer.dart';
import 'customers_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  final CustomerRepository repository;

  CustomersCubit(this.repository) : super(CustomersInitial());

  Future<void> loadCustomers() async {
    emit(CustomersLoading());
    try {
      final customers = await repository.getCustomers();
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      await repository.addCustomer(customer);
      loadCustomers();
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await repository.updateCustomer(customer);
      loadCustomers();
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await repository.deleteCustomer(id);
      loadCustomers();
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }
}
