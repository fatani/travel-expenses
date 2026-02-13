import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/db_providers.dart';
import '../../expenses/presentation/providers/expenses_providers.dart';
import '../../trips/presentation/providers/trips_providers.dart';
import '../services/csv_export_service.dart';
import './csv_export_providers.dart';

/// Provider that returns receipts count per expense for a trip
final receiptsByTripProvider = FutureProvider.autoDispose.family<
    Map<String, int>,
    String>((ref, tripId) async {
  final repository = ref.watch(repositoryProvider);
  
  // Get all expenses for the trip
  final expensesStream = repository.watchExpensesByTrip(tripId);
  final expenses = await expensesStream.first;

  final receiptsCountByExpenseId = <String, int>{};

  for (final expense in expenses) {
    try {
      final receiptsStream = repository.watchReceiptsByExpense(expense.id);
      final receipts = await receiptsStream.first;
      receiptsCountByExpenseId[expense.id] = receipts.length;
    } catch (_) {
      // If error reading receipts, default to 0
      receiptsCountByExpenseId[expense.id] = 0;
    }
  }

  return receiptsCountByExpenseId;
});

/// Provider that generates CSV bytes for trip expenses
final tripCsvExportProvider = FutureProvider.autoDispose.family<Uint8List, String>(
  (ref, tripId) async {
    final csvService = ref.watch(csvExportServiceProvider);

    // Get trip
    final trip = await ref.watch(tripByIdProvider(tripId).future);
    if (trip == null) {
      throw Exception('Trip not found');
    }

    // Get expenses
    final expensesList =
      await ref.watch(watchExpensesByTripProvider(tripId).future);

    // Get receipts count
    final receiptsCount =
        await ref.watch(receiptsByTripProvider(tripId).future);

    // Generate CSV
    return csvService.buildTripExpensesCsvBytes(
      trip: trip,
      expenses: expensesList,
      receiptsCountByExpenseId: receiptsCount,
    );
  },
);

/// Helper provider to get suggested filename for CSV export
final csvExportFilenameProvider =
    FutureProvider.autoDispose.family<String, String>(
  (ref, tripId) async {
    final trip = await ref.watch(tripByIdProvider(tripId).future);
    if (trip == null) {
      return 'trip_expenses.csv';
    }

    return CsvExportService.generateExportFilename(trip);
  },
);
