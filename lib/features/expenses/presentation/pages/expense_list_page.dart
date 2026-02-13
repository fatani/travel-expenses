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

  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod) {
      case 'cash':
        return Icons.payments;
      case 'card':
        return Icons.credit_card;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'other':
        return Icons.more_horiz;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationText = expense.locationText?.trim();
    return ListTile(
      title: Text('${expense.amount} ${expense.currency} • ${expense.category}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            expense.merchant,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (locationText != null && locationText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '📍 $locationText',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPaymentIcon(expense.paymentMethod),
            size: 20,
            color: Colors.grey[600],
          ),
          PopupMenuButton(
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
        ],
      ),
      onTap: onEdit,
    );
  }
}
