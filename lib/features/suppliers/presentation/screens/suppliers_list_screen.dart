import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matjary/features/suppliers/presentation/cubit/suppliers_cubit.dart';
import 'package:matjary/features/suppliers/presentation/cubit/suppliers_state.dart';
import 'package:matjary/features/suppliers/domain/repositories/supplier_repository.dart';
import 'add_supplier_screen.dart';
import 'supplier_details_screen.dart';

class SuppliersListScreen extends StatelessWidget {
  const SuppliersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SuppliersCubit(context.read<SupplierRepository>())..loadSuppliers(),
      child: const SuppliersListView(),
    );
  }
}

class SuppliersListView extends StatelessWidget {
  const SuppliersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الموردين')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFD4AF37),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<SuppliersCubit>(),
                child: const AddSupplierScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: BlocBuilder<SuppliersCubit, SuppliersState>(
        builder: (context, state) {
          if (state is SuppliersLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            );
          } else if (state is SuppliersError) {
            return Center(child: Text('خطأ: ${state.message}'));
          } else if (state is SuppliersLoaded) {
            if (state.suppliers.isEmpty) {
              return const Center(
                child: Text(
                  "لا يوجد موردين حتى الان",
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.suppliers.length,
              itemBuilder: (context, index) {
                final supplier = state.suppliers[index];
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
                        0xFFD4AF37,
                      ).withValues(alpha: 0.2),
                      child: Text(
                        supplier.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      supplier.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      supplier.phone,
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
                              supplier.balance.abs().toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: supplier.balance > 0
                                    ? const Color(0xFFCF6679)
                                    : const Color(0xFF00897B),
                                fontFamily: 'Roboto',
                              ),
                            ),
                            Text(
                              supplier.balance > 0 ? "عليك" : "لك",
                              style: TextStyle(
                                fontSize: 12,
                                color: supplier.balance > 0
                                    ? const Color(0xFFCF6679)
                                    : const Color(0xFF00897B),
                              ),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditSupplierDialog(context, supplier);
                            } else if (value == 'delete') {
                              _confirmDeleteSupplier(context, supplier);
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
                              SupplierDetailsScreen(supplier: supplier),
                        ),
                      ).then((_) {
                        if (context.mounted) {
                          context.read<SuppliersCubit>().loadSuppliers();
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

  void _showEditSupplierDialog(BuildContext context, dynamic supplier) {
    final nameController = TextEditingController(text: supplier.name);
    final phoneController = TextEditingController(text: supplier.phone);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "تعديل المورد",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "اسم المورد",
                prefixIcon: Icon(Icons.person, color: Color(0xFFD4AF37)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "رقم الهاتف",
                prefixIcon: Icon(Icons.phone, color: Color(0xFFD4AF37)),
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
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              final updated = supplier.copyWith(
                name: nameController.text,
                phone: phoneController.text,
              );
              context.read<SuppliersCubit>().updateSupplier(updated);
              Navigator.pop(ctx);
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSupplier(BuildContext context, dynamic supplier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("تأكيد الحذف", style: TextStyle(color: Colors.white)),
        content: Text(
          "هل أنت متأكد من حذف ${supplier.name}؟ سيتم حذف جميع العمليات المرتبطة.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              context.read<SuppliersCubit>().deleteSupplier(
                supplier.id,
              ); // Cubit has delete
              Navigator.pop(ctx);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
