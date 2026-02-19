import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khazina/features/customers/domain/entities/customer.dart';
import 'package:khazina/features/transactions/presentation/cubit/transaction_cubit.dart';
import 'package:khazina/features/transactions/presentation/cubit/transaction_state.dart';
import 'package:khazina/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:khazina/features/customers/domain/repositories/customer_repository.dart';
import 'package:khazina/core/constants/enums.dart';
import 'package:khazina/features/transactions/domain/entities/transaction.dart';
import 'package:khazina/core/constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final Customer customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TransactionCubit(context.read<TransactionRepository>())
            ..loadTransactions(customer.id),
      child: CustomerDetailsView(customer: customer),
    );
  }
}

class CustomerDetailsView extends StatefulWidget {
  final Customer customer;
  const CustomerDetailsView({super.key, required this.customer});

  @override
  State<CustomerDetailsView> createState() => _CustomerDetailsViewState();
}

class _CustomerDetailsViewState extends State<CustomerDetailsView> {
  late Customer currentCustomer;

  @override
  void initState() {
    super.initState();
    currentCustomer = widget.customer;
  }

  void _refreshCustomer() async {
    final updated = await context.read<CustomerRepository>().getCustomer(
      currentCustomer.id,
    );
    if (!mounted) return;
    if (updated != null) {
      setState(() {
        currentCustomer = updated;
      });
    }
    context.read<TransactionCubit>().loadTransactions(currentCustomer.id);
  }

  void _addTransaction(TransactionType type, double amount) async {
    final transaction = Transaction(
      id: const Uuid().v4(),
      partyId: currentCustomer.id,
      partyType: PartyType.customer,
      amount: amount,
      date: DateTime.now(),
      type: type,
    );

    await context.read<TransactionRepository>().addTransaction(transaction);

    if (!mounted) return;

    double newBalance = currentCustomer.balance;
    // Customer Logic:
    // Debt (Sale on credit) => They owe us more (+ve)
    // Payment (They pay us) => They owe us less (-ve)
    if (type == TransactionType.debt) {
      newBalance += amount;
    } else {
      newBalance -= amount;
    }

    final updatedCustomer = currentCustomer.copyWith(balance: newBalance);
    await context.read<CustomerRepository>().updateCustomer(updatedCustomer);

    if (mounted) {
      _refreshCustomer();
    }
  }

  void _deleteTransaction(Transaction transaction) async {
    double newBalance = currentCustomer.balance;
    // Revert logic
    if (transaction.type == TransactionType.debt) {
      newBalance -= transaction.amount;
    } else {
      newBalance += transaction.amount;
    }

    final updatedCustomer = currentCustomer.copyWith(balance: newBalance);
    await context.read<CustomerRepository>().updateCustomer(updatedCustomer);
    setState(() {
      currentCustomer = updatedCustomer;
    });

    if (mounted) {
      await context.read<TransactionCubit>().deleteTransaction(transaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(currentCustomer.name)),
      body: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: AppConstants.kPrimaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "الرصيد الحالي",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  currentCustomer.balance.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    color: currentCustomer.balance > 0
                        ? AppConstants
                              .kSecondaryColor // Green for Asset (Lak)
                        : AppConstants.kErrorColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentCustomer.balance > 0
                      ? "لك (عند العميل)"
                      : "خالص", // Paid fully
                  style: TextStyle(
                    fontSize: 14,
                    color: currentCustomer.balance > 0
                        ? AppConstants.kSecondaryColor
                        : AppConstants.kErrorColor,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.sell, color: Colors.black),
                        label: const Text(
                          "بيع (آجل)",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => _showAddTransactionDialogOfType(
                          TransactionType.debt,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants
                              .kErrorColor, // Redish for debt increasing? Or maybe keep consistent? Let's use generic styles.
                          // Actually, Selling is Good, but it increases debt.
                          // Let's stick to: Debt Action = Red/Warning? Or maybe consistent with Supplier.
                          // Supplier: Debt(Buy) -> Red. Payment(Pay) -> Green (Good).
                          // Customer: Debt(Sell) -> Actually adding asset.
                          // Let's keep the Buttons: Debt=Red, Payment=Green for consistency of "Debt vs Payment" types.
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.attach_money,
                          color: Colors.black,
                        ),
                        label: const Text(
                          "تحصيل", // Receive Payment
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => _showAddTransactionDialogOfType(
                          TransactionType.payment,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.kSecondaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "سجل العمليات",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[300],
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<TransactionCubit, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppConstants.kPrimaryColor,
                    ),
                  );
                }
                if (state is TransactionLoaded) {
                  if (state.transactions.isEmpty) {
                    return const Center(
                      child: Text(
                        "لا يوجد عمليات",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.transactions.length,
                    itemBuilder: (context, index) {
                      final tx = state.transactions[index];
                      final isDebt = tx.type == TransactionType.debt;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              right: BorderSide(
                                color: isDebt
                                    ? AppConstants.kErrorColor
                                    : AppConstants.kSecondaryColor,
                                width: 4,
                              ),
                            ),
                          ),
                          child: ListTile(
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: const Color(0xFF1E1E1E),
                                  title: const Text(
                                    "حذف العملية",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: const Text(
                                    "هل تريد حذف هذه العملية؟ سيتم تعديل الرصيد تلقائياً.",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text(
                                        "إلغاء",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _deleteTransaction(tx);
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text(
                                        "حذف",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            title: Text(
                              isDebt ? "بيع بضاعة" : "تحصيل نقدية",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              tx.date.toString().split('.')[0],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: Text(
                              tx.amount.toStringAsFixed(2),
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDebt
                                    ? AppConstants.kErrorColor
                                    : AppConstants.kSecondaryColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionDialogOfType(TransactionType type) {
    showDialog(
      context: context,
      builder: (ctx) => AddTransactionDialog(
        initialType: type,
        onSubmit: (t, amount) => _addTransaction(t, amount),
      ),
    );
  }
}

class AddTransactionDialog extends StatefulWidget {
  final Function(TransactionType, double) onSubmit;
  final TransactionType? initialType;

  const AddTransactionDialog({
    super.key,
    required this.onSubmit,
    this.initialType,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  late TransactionType _type;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType ?? TransactionType.debt;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("إضافة عملية", style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<TransactionType>(
            initialValue: _type,
            dropdownColor: const Color(0xFF2C2C2C),
            items: const [
              DropdownMenuItem(
                value: TransactionType.debt,
                child: Text("بيع (آجل)", style: TextStyle(color: Colors.white)),
              ),
              DropdownMenuItem(
                value: TransactionType.payment,
                child: Text("تحصيل", style: TextStyle(color: Colors.white)),
              ),
            ],
            onChanged: widget.initialType != null
                ? null
                : (val) => setState(() => _type = val!),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabled: widget.initialType == null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "المبلغ",
              labelStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppConstants.kPrimaryColor),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.kPrimaryColor,
            foregroundColor: Colors.black,
          ),
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            if (amount != null) {
              widget.onSubmit(_type, amount);
              Navigator.pop(context);
            }
          },
          child: const Text(
            "حفظ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
