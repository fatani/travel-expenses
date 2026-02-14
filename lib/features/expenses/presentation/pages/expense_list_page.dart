import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/models/expense.dart';
import '../providers/expense_filters_provider.dart';
import '../providers/expenses_providers.dart';
import '../providers/filtered_expenses_provider.dart';
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
    final originalExpensesAsync = ref.watch(watchExpensesByTripProvider(tripId));
    final filteredExpensesAsync = ref.watch(filteredExpensesProvider(tripId));

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'بحث',
                      hintText: 'ابحث في مكان الشراء، موقع الشراء، الملاحظات',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      ref.read(expenseFiltersProvider(tripId).notifier).setQuery(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'فلترة',
                  onPressed: () => _showFiltersSheet(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredExpensesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => ErrorState(
                title: 'حدث خطأ أثناء تحميل البيانات.',
                actionLabel: 'إعادة المحاولة',
                onAction: () {
                  ref.invalidate(filteredExpensesProvider(tripId));
                  ref.invalidate(watchExpensesByTripProvider(tripId));
                },
              ),
              data: (expenses) {
                final originalExpenses = originalExpensesAsync.asData?.value;
                if (expenses.isEmpty) {
                  if (originalExpenses == null || originalExpenses.isEmpty) {
                    return const EmptyState(
                      icon: Icons.receipt_long,
                      title: 'لا توجد مصاريف بعد',
                      subtitle: 'أضف أول مصروف لتظهر البيانات هنا.',
                    );
                  }
                  // Has expenses but filtered results are empty
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey[500]),
                          const SizedBox(height: 12),
                          Text(
                            'لا توجد نتائج مطابقة',
                            style: Theme.of(context).textTheme.titleMedium,
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              ref.read(expenseFiltersProvider(tripId).notifier).reset();
                            },
                            child: const Text('مسح البحث وإعادة الضبط'),
                          ),
                        ],
                      ),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFiltersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ExpenseFiltersSheet(tripId: tripId),
        );
      },
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

class ExpenseFiltersSheet extends ConsumerWidget {
  final String tripId;

  const ExpenseFiltersSheet({
    required this.tripId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(expenseFiltersProvider(tripId));
    final notifier = ref.read(expenseFiltersProvider(tripId).notifier);
    final paymentOptions = <MapEntry<String?, String>>[
      MapEntry(null, 'الكل'),
      const MapEntry('cash', 'نقد'),
      const MapEntry('card', 'بطاقة'),
      const MapEntry('wallet', 'محفظة'),
      const MapEntry('other', 'أخرى'),
    ];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'فلترة المصاريف',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExpenseCategory?>(
              value: filters.category,
              decoration: const InputDecoration(
                labelText: 'الفئة',
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('الكل'),
                ),
                ...ExpenseCategory.values.map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category.value),
                  ),
                ),
              ],
              onChanged: notifier.setCategory,
            ),
            const SizedBox(height: 16),
            Text(
              'طريقة الدفع',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: paymentOptions.map((option) {
                return ChoiceChip(
                  label: Text(option.value),
                  selected: filters.paymentMethodType == option.key,
                  onSelected: (_) => notifier.setPaymentMethodType(option.key),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'نطاق التاريخ',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickFromDate(context, notifier, filters),
                    child: Text(_formatDateLabel('من', filters.from)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickToDate(context, notifier, filters),
                    child: Text(_formatDateLabel('إلى', filters.to)),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => notifier.setDateRange(null, null),
                child: const Text('مسح التاريخ'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: notifier.reset,
                    child: const Text('إعادة ضبط'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('تطبيق'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromDate(
    BuildContext context,
    ExpenseFiltersNotifier notifier,
    ExpenseFilters filters,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: filters.from ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      notifier.setDateRange(picked, filters.to);
    }
  }

  Future<void> _pickToDate(
    BuildContext context,
    ExpenseFiltersNotifier notifier,
    ExpenseFilters filters,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: filters.to ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      notifier.setDateRange(filters.from, picked);
    }
  }

  String _formatDateLabel(String prefix, DateTime? date) {
    if (date == null) {
      return prefix;
    }
    final formatted =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '$prefix: $formatted';
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

  String _getPaymentTypeLabel(String paymentMethod) {
    switch (paymentMethod) {
      case 'cash':
        return 'نقد';
      case 'card':
        return 'بطاقة';
      case 'wallet':
        return 'محفظة';
      case 'other':
        return 'أخرى';
      default:
        return paymentMethod;
    }
  }

  String _getPaymentBrandLabel(String brand) {
    switch (brand) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'mada':
        return 'Mada';
      case 'amex':
        return 'Amex';
      case 'apple_pay':
        return 'Apple Pay';
      case 'google_pay':
        return 'Google Pay';
      case 'stc_pay':
        return 'STC Pay';
      case 'other':
        return 'Other';
      default:
        return brand;
    }
  }

  String _formatPaymentLine() {
    final parts = <String>[_getPaymentTypeLabel(expense.paymentMethod)];
    final brand = expense.paymentMethodBrand?.trim();
    if (brand != null && brand.isNotEmpty) {
      parts.add(_getPaymentBrandLabel(brand));
    }
    final label = expense.paymentMethodLabel?.trim();
    if (label != null && label.isNotEmpty) {
      parts.add(label);
    }
    return parts.join(' • ');
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
          const SizedBox(height: 4),
          Text(
            _formatPaymentLine(),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
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
