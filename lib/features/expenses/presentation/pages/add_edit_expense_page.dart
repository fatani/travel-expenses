import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/expense.dart';
import '../providers/expenses_providers.dart';

class AddEditExpensePage extends ConsumerStatefulWidget {
  final String tripId;
  final String tripCurrency;
  final Expense? expense;

  const AddEditExpensePage({
    super.key,
    required this.tripId,
    required this.tripCurrency,
    this.expense,
  });

  @override
  ConsumerState<AddEditExpensePage> createState() => _AddEditExpensePageState();
}

class _AddEditExpensePageState extends ConsumerState<AddEditExpensePage> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String _selectedCategory;
  late String _selectedCurrency;
  late DateTime _selectedDate;

  final List<String> _categories = [
    'الطعام',
    'المواصلات',
    'الإقامة',
    'التسوق',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      _amountController = TextEditingController(
        text: widget.expense!.amount.toString(),
      );
      _noteController = TextEditingController(text: widget.expense!.note ?? '');
      _selectedCategory = widget.expense!.category;
      _selectedCurrency = widget.expense!.currency;
      _selectedDate = widget.expense!.date;
    } else {
      _amountController = TextEditingController();
      _noteController = TextEditingController();
      _selectedCategory = _categories.first;
      _selectedCurrency = widget.tripCurrency;
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addOrUpdateExpense() async {
    // Validation
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال المبلغ')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال مبلغ صحيح')),
      );
      return;
    }

    try {
      if (widget.expense != null) {
        // Update
        final updatedExpense = widget.expense!.copyWith(
          amount: amount,
          currency: _selectedCurrency,
          date: _selectedDate,
          category: _selectedCategory,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        );
        await ref.read(expenseProvider.notifier).updateExpense(
              expense: updatedExpense,
            );
      } else {
        // Insert
        await ref.read(expenseProvider.notifier).insertExpense(
              tripId: widget.tripId,
              amount: amount,
              currency: _selectedCurrency,
              date: _selectedDate,
              category: _selectedCategory,
              note: _noteController.text.isEmpty ? null : _noteController.text,
            );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              isEditing ? 'تعديل مصروف' : 'إضافة مصروف',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Amount field
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                hintText: 'أدخل المبلغ',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Currency field
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(
                labelText: 'العملة',
                prefixIcon: Icon(Icons.currency_exchange),
              ),
              items: ['USD', 'EUR', 'GBP', 'SAR', 'AED', 'KWD', 'QAR']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Category field
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'الفئة',
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Date field
            GestureDetector(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'التاريخ',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Note field
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات (اختياري)',
                hintText: 'أضف ملاحظات عن هذا المصروف',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addOrUpdateExpense,
                    child: Text(isEditing ? 'تحديث' : 'إضافة'),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}
