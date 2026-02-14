import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/expense.dart';
import '../providers/expense_filters_provider.dart';
import '../providers/expenses_providers.dart';

final filteredExpensesProvider =
    Provider.autoDispose.family<AsyncValue<List<Expense>>, String>(
  (ref, tripId) {
    final expensesAsync = ref.watch(watchExpensesByTripProvider(tripId));
    final filters = ref.watch(expenseFiltersProvider(tripId));
    return expensesAsync.whenData(
      (items) => applyExpenseFilters(items, filters),
    );
  },
);
