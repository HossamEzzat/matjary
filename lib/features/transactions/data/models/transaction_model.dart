import 'package:hive/hive.dart';
import 'package:matjary/core/constants/enums.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 2)
class TransactionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String partyId;

  @HiveField(2)
  late String partyType; // Stored as String

  @HiveField(3)
  late double amount;

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  late String transactionType; // Stored as String

  @HiveField(6)
  late String? note;

  TransactionModel({
    required this.id,
    required this.partyId,
    required this.partyType,
    required this.amount,
    required this.date,
    required this.transactionType,
    this.note,
  });

  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      partyId: entity.partyId,
      partyType: entity.partyType.name,
      amount: entity.amount,
      date: entity.date,
      transactionType: entity.type.name,
      note: entity.note,
    );
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      partyId: partyId,
      partyType: PartyType.values.byName(partyType),
      amount: amount,
      date: date,
      type: TransactionType.values.byName(transactionType),
      note: note,
    );
  }
}
