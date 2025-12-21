import 'package:matjary/features/suppliers/data/datasources/supplier_local_data_source.dart';
import 'package:matjary/features/suppliers/data/models/supplier_model.dart';
import 'package:matjary/features/suppliers/domain/entities/supplier.dart';
import 'package:matjary/features/suppliers/domain/repositories/supplier_repository.dart';

class SupplierRepositoryImpl implements SupplierRepository {
  final SupplierLocalDataSource localDataSource;

  SupplierRepositoryImpl({required this.localDataSource});

  @override
  Future<void> addSupplier(Supplier supplier) async {
    final model = SupplierModel.fromEntity(supplier);
    await localDataSource.addSupplier(model);
  }

  @override
  Future<void> deleteSupplier(String id) async {
    await localDataSource.deleteSupplier(id);
  }

  @override
  Future<Supplier?> getSupplier(String id) async {
    // This requires implementing getSupplier in generic DataSource if needed,
    // or just filtering from list if box not indexed by ID (but we used ID as key).
    // Accessing box by key directly is efficient.
    // However, the DataSource interface I wrote returns List or takes ID.
    // I can assume the DataSource *could* expose 'get(id)'.
    // Let's rely on getSuppliers() for now or update DataSource.
    // Update: I used `supplierBox.put(id, model)`, so `supplierBox.get(id)` works.
    // I should add `getSupplier` to DataSource.
    // For now, let's implement the list retrieval.
    final suppliers = await localDataSource.getSuppliers();
    try {
      return suppliers.firstWhere((element) => element.id == id).toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Supplier>> getSuppliers() async {
    final models = await localDataSource.getSuppliers();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> updateSupplier(Supplier supplier) async {
    await localDataSource.updateSupplier(SupplierModel.fromEntity(supplier));
  }
}
