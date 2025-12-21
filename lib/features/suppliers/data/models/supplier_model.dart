import 'package:hive/hive.dart';
import '../../domain/entities/supplier.dart';

part 'supplier_model.g.dart';

@HiveType(typeId: 0)
class SupplierModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String phone;

  @HiveField(3)
  late double balance;

  SupplierModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
  });

  factory SupplierModel.fromEntity(Supplier entity) {
    return SupplierModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      balance: entity.balance,
    );
  }

  Supplier toEntity() {
    return Supplier(id: id, name: name, phone: phone, balance: balance);
  }
}
