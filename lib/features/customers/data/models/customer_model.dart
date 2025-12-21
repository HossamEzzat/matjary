import 'package:hive/hive.dart';
import '../../domain/entities/customer.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 1)
class CustomerModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String phone;

  @HiveField(3)
  late double balance;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.balance,
  });

  factory CustomerModel.fromEntity(Customer entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      balance: entity.balance,
    );
  }

  Customer toEntity() {
    return Customer(id: id, name: name, phone: phone, balance: balance);
  }
}
