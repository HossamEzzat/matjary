import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final String id;
  final String name;
  final String phone;
  final double
  balance; // Positive means we owe them? Or simply the net balance.
  // Standard: Positive balance for a Supplier usually means we owe them.

  const Supplier({
    required this.id,
    required this.name,
    required this.phone,
    this.balance = 0.0,
  });

  Supplier copyWith({
    String? id,
    String? name,
    String? phone,
    double? balance,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      balance: balance ?? this.balance,
    );
  }

  @override
  List<Object> get props => [id, name, phone, balance];
}
