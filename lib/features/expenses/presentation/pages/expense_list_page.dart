import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/expense.dart';
import '../providers/expenses_providers.dart';
import 'add_edit_expense_page.dart';

class ExpenseListPage extends ConsumerWidget {
  final String tripId;
  final String tripCurrency;

  const ExpenseListPage({
    super.key,
    required this.tripId,
    required this.tripCurrency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(watchExpensesByTripProvider(tripId));

    return Scaffold(
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('خطأ: $error')),
        data: (expenses) {
          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لا توجد مصاريف بعد'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddExpenseSheet(context, ref),
                    child: const Text('إضافة مصروف'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return _ExpenseListItem(
                expense: expense,
                tripId: tripId,
                tripCurrency: tripCurrency,
                onDelete: () => _showDeleteConfirmation(context, ref, expense),
                onEdit: () => _showEditExpenseSheet(context, ref, expense),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExpenseSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddEditExpensePage(
            tripId: tripId,
            tripCurrency: tripCurrency,
          ),
        );
      },
    );
  }

  void _showEditExpenseSheet(BuildContext context, WidgetRef ref, Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddEditExpensePage(
            tripId: tripId,
            tripCurrency: tripCurrency,
            expense: expense,
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Expense expense,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف المصروف'),
          content: const Text('هل أنت متأكد من حذف هذا المصروف؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                ref.read(expenseProvider.notifier).deleteExpense(
                      expenseId: expense.id,
                    );
                Navigator.pop(context);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }
}

class _ExpenseListItem extends StatelessWidget {
  final Expense expense;
  final String tripId;
  final String tripCurrency;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ExpenseListItem({
    required this.expense,
    required this.tripId,
    required this.tripCurrency,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${expense.amount} ${expense.currency}'),
      subtitle: Text(expense.category),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: onEdit,
            child: const Text('تعديل'),
          ),
          PopupMenuItem(
            onTap: onDelete,
            child: const Text('حذف'),
          ),
        ],
      ),
      onTap: onEdit,
    );
  }
}
