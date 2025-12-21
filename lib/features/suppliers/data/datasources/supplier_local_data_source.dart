import 'package:hive_flutter/hive_flutter.dart';

import '../models/supplier_model.dart';

abstract class SupplierLocalDataSource {
  Future<List<SupplierModel>> getSuppliers();
  Future<void> addSupplier(SupplierModel supplier);
  Future<void> updateSupplier(SupplierModel supplier);
  Future<void> deleteSupplier(String id);
}

class SupplierLocalDataSourceImpl implements SupplierLocalDataSource {
  final Box<SupplierModel> supplierBox;

  SupplierLocalDataSourceImpl({required this.supplierBox});

  @override
  Future<List<SupplierModel>> getSuppliers() async {
    return supplierBox.values.toList();
  }

  @override
  Future<void> addSupplier(SupplierModel supplier) async {
    await supplierBox.put(supplier.id, supplier); // Use ID as key
  }

  @override
  Future<void> updateSupplier(SupplierModel supplier) async {
    await supplierBox.put(supplier.id, supplier);
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await supplierBox.delete(id);
  }
}
