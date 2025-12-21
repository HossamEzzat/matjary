import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/supplier_repository.dart';
import '../../domain/entities/supplier.dart';
import 'suppliers_state.dart';

class SuppliersCubit extends Cubit<SuppliersState> {
  final SupplierRepository repository;

  SuppliersCubit(this.repository) : super(SuppliersInitial());

  Future<void> loadSuppliers() async {
    emit(SuppliersLoading());
    try {
      final suppliers = await repository.getSuppliers();
      emit(SuppliersLoaded(suppliers));
    } catch (e) {
      emit(SuppliersError(e.toString()));
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    try {
      await repository.addSupplier(supplier);
      loadSuppliers();
    } catch (e) {
      emit(SuppliersError(e.toString()));
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    try {
      await repository.updateSupplier(supplier);
      loadSuppliers();
    } catch (e) {
      emit(SuppliersError(e.toString()));
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await repository.deleteSupplier(id);
      loadSuppliers();
    } catch (e) {
      emit(SuppliersError(e.toString()));
    }
  }
}
