import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/app_repository.dart';
import '../../../../core/db/db_providers.dart';
import '../../../../core/models/expense.dart';

/// Stream provider to watch expenses by trip
/// 
/// autoDispose: Allows cleanup when not in view
final watchExpensesByTripProvider =
    StreamProvider.autoDispose.family<List<Expense>, String>((ref, tripId) {
  final repository = ref.watch(repositoryProvider);
  return repository.watchExpensesByTrip(tripId);
});

/// Notifier for expense CRUD operations
class ExpenseNotifier extends StateNotifier<AsyncValue<void>> {
  final AppRepository repository;

  ExpenseNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> insertExpense({
    required String tripId,
    required double amount,
    required String currency,
    required DateTime date,
    required String category,
    String? note,
    String? id, // Optional: use this ID if provided
  }) async {
    state = const AsyncValue.loading();
    try {
      final expense = Expense(
        id: id ?? const Uuid().v4(),
        tripId: tripId,
        amount: amount,
        currency: currency,
        date: date,
        category: category,
        note: note,
        createdAt: DateTime.now(),
      );
      await repository.insertExpense(expense);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateExpense({
    required Expense expense,
  }) async {
    state = const AsyncValue.loading();
    try {
      await repository.updateExpense(expense);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteExpense({required String expenseId}) async {
    state = const AsyncValue.loading();
    try {
      await repository.deleteExpense(expenseId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for expense notifier
final expenseProvider = StateNotifierProvider<ExpenseNotifier, AsyncValue<void>>(
  (ref) {
    final repository = ref.watch(repositoryProvider);
    return ExpenseNotifier(repository);
  },
);
