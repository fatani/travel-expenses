import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/expense.dart';
import '../models/trip_summary.dart';
import '../providers/expense_filters_provider.dart';
import '../providers/expenses_providers.dart';

/// Helper function to build a trip summary from expenses (pure function)
TripSummary buildTripSummary(List<Expense> expenses) {
  final totalByCurrency = <String, double>{};
  final totalByCategory = <ExpenseCategory, double>{};
  final totalByDay = <DateTime, double>{};

  for (final expense in expenses) {
    // Total by currency
    totalByCurrency.update(
      expense.currency,
      (sum) => sum + expense.amount,
      ifAbsent: () => expense.amount,
    );

    // Total by category
    final category = ExpenseCategory.values.firstWhere(
      (c) => c.value == expense.category,
      orElse: () => ExpenseCategory.other,
    );
    totalByCategory.update(
      category,
      (sum) => sum + expense.amount,
      ifAbsent: () => expense.amount,
    );

    // Total by day (Date only, no time)
    final dayKey = DateTime(
      expense.date.year,
      expense.date.month,
      expense.date.day,
    );
    totalByDay.update(
      dayKey,
      (sum) => sum + expense.amount,
      ifAbsent: () => expense.amount,
    );
  }

  return TripSummary(
    totalByCurrency: totalByCurrency,
    totalByCategory: totalByCategory,
    totalByDay: totalByDay,
  );
}

/// Provider that computes trip summary from original (unfiltered) expenses
final tripSummaryProvider =
    Provider.autoDispose.family<AsyncValue<TripSummary>, String>(
  (ref, tripId) {
    final expensesAsync = ref.watch(watchExpensesByTripProvider(tripId));
    return expensesAsync.whenData((expenses) => buildTripSummary(expenses));
  },
);
