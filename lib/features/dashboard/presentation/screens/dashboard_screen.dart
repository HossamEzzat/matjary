import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khazina/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:khazina/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:khazina/features/suppliers/presentation/screens/suppliers_list_screen.dart';
import 'package:khazina/features/customers/presentation/screens/customers_list_screen.dart';
import 'package:khazina/features/transactions/presentation/screens/transactions_list_screen.dart';
import 'package:khazina/features/suppliers/domain/repositories/supplier_repository.dart';
import 'package:khazina/features/customers/domain/repositories/customer_repository.dart';
import 'package:khazina/features/transactions/domain/entities/transaction.dart';
import 'package:khazina/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:khazina/core/constants/enums.dart';
import 'package:khazina/features/dashboard/presentation/cubit/dashboard_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(
        supplierRepository: context.read<SupplierRepository>(),
        customerRepository: context.read<CustomerRepository>(),
        transactionRepository: context.read<TransactionRepository>(),
      )..loadDashboardData(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Khazina - خزينة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFF59E0B)),
              );
            } else if (state is DashboardError) {
              return Center(child: Text('خطأ: ${state.message}'));
            } else if (state is DashboardLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTreasuryCard(
                      context,
                      'خزينة المحل',
                      state.totalTreasury,
                      const Color(0xFFF59E0B),
                      Icons.account_balance_wallet_rounded,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            context,
                            'عليك',
                            state.totalPayables,
                            const Color(0xFFEF4444),
                            Icons.arrow_circle_down_rounded,
                            isSmall: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            context,
                            'لك',
                            state.totalReceivables,
                            const Color(0xFF10B981),
                            Icons.arrow_circle_up_rounded,
                            isSmall: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildMenuButton(
                      context,
                      'إدارة الموردين',
                      Icons.people_outline,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SuppliersListScreen(),
                          ),
                        ).then((_) {
                          if (context.mounted) {
                            context.read<DashboardCubit>().loadDashboardData();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuButton(
                      context,
                      'إدارة العملاء',
                      Icons.supervised_user_circle_outlined,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CustomersListScreen(),
                          ),
                        ).then((_) {
                          if (context.mounted) {
                            context.read<DashboardCubit>().loadDashboardData();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuButton(
                      context,
                      'سجل المعاملات',
                      Icons.receipt_long,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TransactionsListScreen(),
                          ),
                        ).then((_) {
                          if (context.mounted) {
                            context.read<DashboardCubit>().loadDashboardData();
                          }
                        });
                      },
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTreasuryCard(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                    ),
                    onPressed: () => _showManageTreasuryDialog(context),
                    tooltip: 'إدارة الخزينة',
                  ),
                  Icon(icon, color: Colors.white, size: 28),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Roboto',
            ),
          ),
          const Text(
            'جنيه',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showManageTreasuryDialog(BuildContext context) {
    final amountController = TextEditingController();
    bool isDeposit = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text("إدارة الخزينة"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("إيداع"),
                      selected: isDeposit,
                      onSelected: (val) => setState(() => isDeposit = true),
                      selectedColor: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text("سحب"),
                      selected: !isDeposit,
                      onSelected: (val) => setState(() => isDeposit = false),
                      selectedColor: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "المبلغ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDeposit
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  final finalAmount = isDeposit ? amount : -amount;
                  final tx = Transaction(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    partyId: 'internal',
                    partyType: PartyType.internal,
                    amount: finalAmount,
                    date: DateTime.now(),
                    type: TransactionType.payment,
                    note: isDeposit ? 'إيداع يدوي' : 'سحب يدوي',
                  );

                  await context.read<TransactionRepository>().addTransaction(
                    tx,
                  );
                  if (context.mounted) {
                    context.read<DashboardCubit>().loadDashboardData();
                    Navigator.pop(ctx);
                  }
                }
              },
              child: Text(isDeposit ? "تأكيد الإيداع" : "تأكيد السحب"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double amount,
    Color color,
    IconData icon, {
    bool isSmall = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Slate Card
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      padding: EdgeInsets.all(isSmall ? 16 : 24),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmall ? 8 : 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: isSmall ? 24 : 32),
          ),
          SizedBox(width: isSmall ? 12 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmall ? 12 : 16,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  amount.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: isSmall ? 18 : 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFF59E0B), size: 28),
              ),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
