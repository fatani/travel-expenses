import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/expense.dart';

/// Expense categories used for filtering (match stored category strings).
enum ExpenseCategory {
  food('الطعام'),
  transport('المواصلات'),
  lodging('الإقامة'),
  shopping('التسوق'),
  other('أخرى');

  const ExpenseCategory(this.value);
  final String value;
}

class ExpenseFilters {
  final String query;
  final ExpenseCategory? category;
  final String? paymentMethodType;
  final DateTime? from;
  final DateTime? to;

  const ExpenseFilters({
    this.query = '',
    this.category,
    this.paymentMethodType,
    this.from,
    this.to,
  });
}

class ExpenseFiltersNotifier
    extends AutoDisposeFamilyNotifier<ExpenseFilters, String> {
  @override
  ExpenseFilters build(String arg) => const ExpenseFilters();

  void setQuery(String value) {
    state = ExpenseFilters(
      query: value,
      category: state.category,
      paymentMethodType: state.paymentMethodType,
      from: state.from,
      to: state.to,
    );
  }

  void setCategory(ExpenseCategory? category) {
    state = ExpenseFilters(
      query: state.query,
      category: category,
      paymentMethodType: state.paymentMethodType,
      from: state.from,
      to: state.to,
    );
  }

  void setPaymentMethodType(String? paymentMethodType) {
    state = ExpenseFilters(
      query: state.query,
      category: state.category,
      paymentMethodType: paymentMethodType,
      from: state.from,
      to: state.to,
    );
  }

  void setDateRange(DateTime? from, DateTime? to) {
    state = ExpenseFilters(
      query: state.query,
      category: state.category,
      paymentMethodType: state.paymentMethodType,
      from: from,
      to: to,
    );
  }

  void reset() {
    state = const ExpenseFilters();
  }
}

final expenseFiltersProvider = NotifierProvider.autoDispose
    .family<ExpenseFiltersNotifier, ExpenseFilters, String>(
  ExpenseFiltersNotifier.new,
);

List<Expense> applyExpenseFilters(List<Expense> items, ExpenseFilters filters) {
  final query = filters.query.trim().toLowerCase();
  final hasQuery = query.isNotEmpty;
  final fromDate = filters.from == null ? null : _dateOnly(filters.from!);
  final toDate = filters.to == null ? null : _dateOnly(filters.to!);

  return items.where((expense) {
    if (filters.category != null && expense.category != filters.category!.value) {
      return false;
    }

    if (filters.paymentMethodType != null &&
        expense.paymentMethod != filters.paymentMethodType) {
      return false;
    }

    if (fromDate != null || toDate != null) {
      final expenseDate = _dateOnly(expense.date);
      if (fromDate != null && expenseDate.isBefore(fromDate)) {
        return false;
      }
      if (toDate != null && expenseDate.isAfter(toDate)) {
        return false;
      }
    }

    if (hasQuery) {
      final haystack = [
        expense.merchant,
        expense.locationText,
        expense.note,
      ].whereType<String>().join(' ').toLowerCase();

      if (!haystack.contains(query)) {
        return false;
      }
    }

    return true;
  }).toList();
}

DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);
