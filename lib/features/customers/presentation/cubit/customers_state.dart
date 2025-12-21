import 'package:equatable/equatable.dart';
import 'package:matjary/features/customers/domain/entities/customer.dart';

abstract class CustomersState extends Equatable {
  const CustomersState();

  @override
  List<Object> get props => [];
}

class CustomersInitial extends CustomersState {}

class CustomersLoading extends CustomersState {}

class CustomersLoaded extends CustomersState {
  final List<Customer> customers;

  const CustomersLoaded(this.customers);

  @override
  List<Object> get props => [customers];
}

class CustomersError extends CustomersState {
  final String message;

  const CustomersError(this.message);

  @override
  List<Object> get props => [message];
}
