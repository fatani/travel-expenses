import 'package:flutter_test/flutter_test.dart';

import 'package:travel_expenses/core/models/expense.dart';
import 'package:travel_expenses/features/expenses/presentation/providers/expense_filters_provider.dart';
import 'package:travel_expenses/features/expenses/presentation/providers/trip_summary_provider.dart';

Expense _expense({
  required String id,
  required String tripId,
  required double amount,
  required String currency,
  required String category,
  required String merchant,
  DateTime? date,
}) {
  return Expense(
    id: id,
    tripId: tripId,
    amount: amount,
    currency: currency,
    date: date ?? DateTime(2025, 1, 10, 15, 30),
    category: category,
    note: null,
    merchant: merchant,
    paymentMethod: 'cash',
    paymentMethodBrand: null,
    paymentMethodLabel: null,
    locationText: null,
    createdAt: DateTime(2025, 1, 10, 16, 0),
  );
}

void main() {
  test('buildTripSummary calculates total by two currencies', () {
    final items = [
      _expense(
        id: '1',
        tripId: 't1',
        amount: 100,
        currency: 'USD',
        category: 'الطعام',
        merchant: 'Cafe',
      ),
      _expense(
        id: '2',
        tripId: 't1',
        amount: 50,
        currency: 'USD',
        category: 'الطعام',
        merchant: 'Burger',
      ),
      _expense(
        id: '3',
        tripId: 't1',
        amount: 75,
        currency: 'SAR',
        category: 'المواصلات',
        merchant: 'Uber',
      ),
    ];

    final summary = buildTripSummary(items);

    expect(summary.totalByCurrency['USD'], 150);
    expect(summary.totalByCurrency['SAR'], 75);
    expect(summary.grandTotal, 225);
  });

  test('buildTripSummary calculates total by category', () {
    final items = [
      _expense(
        id: '1',
        tripId: 't1',
        amount: 100,
        currency: 'USD',
        category: 'الطعام',
        merchant: 'A',
      ),
      _expense(
        id: '2',
        tripId: 't1',
        amount: 50,
        currency: 'USD',
        category: 'الطعام',
        merchant: 'B',
      ),
      _expense(
        id: '3',
        tripId: 't1',
        amount: 75,
        currency: 'USD',
        category: 'المواصلات',
        merchant: 'C',
      ),
    ];

    final summary = buildTripSummary(items);

    expect(summary.totalByCategory[ExpenseCategory.food], 150);
    expect(summary.totalByCategory[ExpenseCategory.transport], 75);
  });

  test('buildTripSummary calculates total by day (ignores time)', () {
    final day1 = DateTime(2025, 1, 10);
    final day2 = DateTime(2025, 1, 11);

    final items = [
      _expense(
        id: '1',
        tripId: 't1',
        amount: 100,
        currency: 'USD',
        category: 'الطعام',
        merchant: 'A',
        date: day1.add(const Duration(hours: 9, minutes: 30)),
      ),
      _expense(
        id: '2',
        tripId: 't1',
        amount: 50,
        currency: 'USD',
        category: 'الطعام',
        merchant: 'B',
        date: day1.add(const Duration(hours: 18, minutes: 45)),
      ),
      _expense(
        id: '3',
        tripId: 't1',
        amount: 75,
        currency: 'USD',
        category: 'المواصلات',
        merchant: 'C',
        date: day2.add(const Duration(hours: 10)),
      ),
    ];

    final summary = buildTripSummary(items);

    expect(summary.totalByDay[day1], 150);
    expect(summary.totalByDay[day2], 75);
    expect(summary.totalByDay.length, 2);
  });

  test('buildTripSummary handles empty expenses list', () {
    final summary = buildTripSummary([]);

    expect(summary.totalByCurrency.isEmpty, true);
    expect(summary.totalByCategory.isEmpty, true);
    expect(summary.totalByDay.isEmpty, true);
    expect(summary.grandTotal, 0);
  });

  test('buildTripSummary accumulates expenses with same day correctly', () {
    final day = DateTime(2025, 1, 15);

    final items = [
      _expense(
        id: '1',
        tripId: 't1',
        amount: 30,
        currency: 'USD',
        category: 'الطعام',
        merchant: 'A',
        date: day.add(const Duration(hours: 8)),
      ),
      _expense(
        id: '2',
        tripId: 't1',
        amount: 20,
        currency: 'USD',
        category: 'الطعام',
        merchant: 'B',
        date: day.add(const Duration(hours: 18)),
      ),
    ];

    final summary = buildTripSummary(items);

    expect(summary.totalByDay.length, 1);
    expect(summary.totalByDay[day], 50);
  });
}
