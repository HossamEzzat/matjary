import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khazina/features/customers/presentation/cubit/customers_cubit.dart';
import 'package:khazina/features/customers/presentation/cubit/customers_state.dart';
import 'package:khazina/features/customers/presentation/screens/add_customer_screen.dart';
import 'package:khazina/features/customers/presentation/screens/customer_details_screen.dart';
import 'package:khazina/features/customers/domain/repositories/customer_repository.dart';
import 'package:khazina/core/constants/app_constants.dart';

class CustomersListScreen extends StatelessWidget {
  const CustomersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CustomersCubit(context.read<CustomerRepository>())..loadCustomers(),
      child: const CustomersListView(),
    );
  }
}

class CustomersListView extends StatelessWidget {
  const CustomersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العملاء')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.kPrimaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CustomersCubit>(),
                child: const AddCustomerScreen(),
              ),
            ),
          ).then((_) {
            if (context.mounted) {
              context.read<CustomersCubit>().loadCustomers();
            }
          });
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: BlocBuilder<CustomersCubit, CustomersState>(
        builder: (context, state) {
          if (state is CustomersLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFF59E0B)),
            );
          } else if (state is CustomersError) {
            return Center(child: Text('خطأ: ${state.message}'));
          } else if (state is CustomersLoaded) {
            if (state.customers.isEmpty) {
              return const Center(
                child: Text(
                  "لا يوجد عملاء حتى الان",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.customers.length,
              itemBuilder: (context, index) {
                final customer = state.customers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: const Color(0xFF1E1E1E),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(
                        0xFFF59E0B,
                      ).withValues(alpha: 0.1),
                      child: Text(
                        customer.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      customer.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      customer.phone,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              customer.balance.abs().toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: customer.balance > 0
                                    ? AppConstants.kSecondaryColor
                                    : AppConstants.kErrorColor,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            Text(
                              customer.balance > 0 ? "لك" : "عليك",
                              style: TextStyle(
                                fontSize: 12,
                                color: customer.balance > 0
                                    ? AppConstants.kSecondaryColor
                                    : AppConstants.kErrorColor,
                              ),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditCustomerDialog(context, customer);
                            } else if (value == 'delete') {
                              _confirmDeleteCustomer(context, customer);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text("تعديل"),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "حذف",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CustomerDetailsScreen(customer: customer),
                        ),
                      ).then((_) {
                        if (context.mounted) {
                          context.read<CustomersCubit>().loadCustomers();
                        }
                      });
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showEditCustomerDialog(BuildContext context, dynamic customer) {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "تعديل العميل",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "اسم العميل",
                prefixIcon: Icon(Icons.person, color: Color(0xFFF59E0B)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "رقم الهاتف",
                prefixIcon: Icon(Icons.phone, color: Color(0xFFF59E0B)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              final updated = customer.copyWith(
                name: nameController.text,
                phone: phoneController.text,
              );
              context.read<CustomersCubit>().updateCustomer(updated);
              Navigator.pop(ctx);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCustomer(BuildContext context, dynamic customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("تأكيد الحذف", style: TextStyle(color: Colors.white)),
        content: Text(
          "هل أنت متأكد من حذف ${customer.name}؟ سيتم حذف جميع العمليات المرتبطة.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              context.read<CustomersCubit>().deleteCustomer(customer.id);
              Navigator.pop(ctx);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
