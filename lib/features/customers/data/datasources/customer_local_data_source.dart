import 'package:hive_flutter/hive_flutter.dart';
import '../models/customer_model.dart';

abstract class CustomerLocalDataSource {
  Future<List<CustomerModel>> getCustomers();
  Future<void> addCustomer(CustomerModel customer);
  Future<void> updateCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String id);
}

class CustomerLocalDataSourceImpl implements CustomerLocalDataSource {
  final Box<CustomerModel> customerBox;

  CustomerLocalDataSourceImpl({required this.customerBox});

  @override
  Future<List<CustomerModel>> getCustomers() async {
    return customerBox.values.toList();
  }

  @override
  Future<void> addCustomer(CustomerModel customer) async {
    await customerBox.put(customer.id, customer);
  }

  @override
  Future<void> updateCustomer(CustomerModel customer) async {
    await customerBox.put(customer.id, customer);
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await customerBox.delete(id);
  }
}
