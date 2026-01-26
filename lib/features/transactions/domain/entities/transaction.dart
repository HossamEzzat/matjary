import 'package:equatable/equatable.dart';
import 'package:khazina/core/constants/enums.dart';

class Transaction extends Equatable {
  final String id;
  final String partyId;
  final PartyType partyType;
  final double amount;
  final DateTime date;
  final String? note;
  final TransactionType type; // Debt or Payment

  const Transaction({
    required this.id,
    required this.partyId,
    required this.partyType,
    required this.amount,
    required this.date,
    required this.type,
    this.note,
  });

  @override
  List<Object?> get props => [id, partyId, partyType, amount, date, note, type];
}
