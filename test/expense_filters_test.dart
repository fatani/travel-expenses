import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travel_expenses/core/models/expense.dart';
import 'package:travel_expenses/features/expenses/presentation/providers/expense_filters_provider.dart';

Expense _expense({
  required String id,
  required String tripId,
  required String merchant,
  required String category,
  required String paymentMethod,
  DateTime? date,
  String? note,
  String? locationText,
}) {
  return Expense(
    id: id,
    tripId: tripId,
    amount: 10,
    currency: 'SAR',
    date: date ?? DateTime(2025, 1, 10, 15, 30),
    category: category,
    note: note,
    merchant: merchant,
    paymentMethod: paymentMethod,
    paymentMethodBrand: null,
    paymentMethodLabel: null,
    locationText: locationText,
    createdAt: DateTime(2025, 1, 10, 16, 00),
  );
}

void main() {
  test('query filters merchant/location/note (case-insensitive)', () {
    final items = [
      _expense(
        id: '1',
        tripId: 't1',
        merchant: 'Starbucks',
        category: 'الطعام',
        paymentMethod: 'cash',
        locationText: 'Taksim Square',
      ),
      _expense(
        id: '2',
        tripId: 't1',
        merchant: 'Uber',
        category: 'المواصلات',
        paymentMethod: 'card',
        note: 'Late night ride',
      ),
    ];

    final filters = const ExpenseFilters(query: 'taksim');
    final result = applyExpenseFilters(items, filters);

    expect(result.length, 1);
    expect(result.first.id, '1');
  });

  test('category filters when selected', () {
    final items = [
      _expense(
        id: '1',
        tripId: 't1',
        merchant: 'Cafe',
        category: 'الطعام',
        paymentMethod: 'cash',
      ),
      _expense(
        id: '2',
        tripId: 't1',
        merchant: 'Hotel',
        category: 'الإقامة',
        paymentMethod: 'card',
      ),
    ];

    final filters = ExpenseFilters(category: ExpenseCategory.food);
    final result = applyExpenseFilters(items, filters);

    expect(result.length, 1);
    expect(result.first.id, '1');
  });

  test('payment method filters when selected', () {
    final items = [
      _expense(
        id: '1',
        tripId: 't1',
        merchant: 'Cafe',
        category: 'الطعام',
        paymentMethod: 'cash',
      ),
      _expense(
        id: '2',
        tripId: 't1',
        merchant: 'Store',
        category: 'التسوق',
        paymentMethod: 'card',
      ),
    ];

    final filters = const ExpenseFilters(paymentMethodType: 'card');
    final result = applyExpenseFilters(items, filters);

    expect(result.length, 1);
    expect(result.first.id, '2');
  });

  test('date range is inclusive with date-only comparison', () {
    final items = [
      _expense(
        id: '1',
        tripId: 't1',
        merchant: 'A',
        category: 'أخرى',
        paymentMethod: 'cash',
        date: DateTime(2025, 1, 10, 23, 59),
      ),
      _expense(
        id: '2',
        tripId: 't1',
        merchant: 'B',
        category: 'أخرى',
        paymentMethod: 'cash',
        date: DateTime(2025, 1, 12, 0, 1),
      ),
      _expense(
        id: '3',
        tripId: 't1',
        merchant: 'C',
        category: 'أخرى',
        paymentMethod: 'cash',
        date: DateTime(2025, 1, 13, 0, 0),
      ),
    ];

    final filters = ExpenseFilters(
      from: DateTime(2025, 1, 10, 1, 0),
      to: DateTime(2025, 1, 12, 23, 0),
    );
    final result = applyExpenseFilters(items, filters);

    expect(result.length, 2);
    expect(result.map((e) => e.id), ['1', '2']);
  });

  test('reset clears all filters', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(expenseFiltersProvider.notifier);
    notifier.setQuery('test');
    notifier.setCategory(ExpenseCategory.shopping);
    notifier.setPaymentMethodType('wallet');
    notifier.setDateRange(DateTime(2025, 1, 1), DateTime(2025, 1, 2));

    notifier.reset();

    final state = container.read(expenseFiltersProvider);
    expect(state.query, '');
    expect(state.category, isNull);
    expect(state.paymentMethodType, isNull);
    expect(state.from, isNull);
    expect(state.to, isNull);
  });
}
