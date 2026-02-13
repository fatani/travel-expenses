import 'package:drift/drift.dart';

import '../../features/trips/data/models/trip_table.dart' as trip_table;
import '../../features/trips/data/models/expense_table.dart' as expense_table;
import '../../features/trips/data/models/receipt_table.dart' as receipt_table;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    trip_table.TripsTable,
    expense_table.ExpensesTable,
    receipt_table.ReceiptsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  Future<bool> _hasColumn(String tableName, String columnName) async {
    final rows = await customSelect('PRAGMA table_info($tableName);').get();
    for (final row in rows) {
      if (row.read<String>('name') == columnName) {
        return true;
      }
    }
    return false;
  }

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from == 1 && to >= 2) {
        // Add new columns to receipts table
        await m.addColumn(receiptsTable, receiptsTable.data);
        await m.alterTable(TableMigration(
          receiptsTable,
          columnTransformer: {
            receiptsTable.localPath: receiptsTable.localPath,
          },
        ));
      }

      if (from <= 2 && to >= 3) {
        // Add merchant and paymentMethod to expenses table
        if (!await _hasColumn('expenses_table', 'merchant')) {
          await m.addColumn(expensesTable, expensesTable.merchant);
        }
        if (!await _hasColumn('expenses_table', 'payment_method')) {
          await m.addColumn(expensesTable, expensesTable.paymentMethod);
        }

        await customStatement(
          "UPDATE expenses_table SET merchant = 'غير محدد' WHERE merchant IS NULL",
        );
        await customStatement(
          "UPDATE expenses_table SET payment_method = 'cash' WHERE payment_method IS NULL",
        );
      }

      if (from <= 3 && to >= 4) {
        // Add optional location text to expenses table
        if (!await _hasColumn('expenses_table', 'location_text')) {
          await m.addColumn(expensesTable, expensesTable.locationText);
        }
      }

      if (from <= 4 && to >= 5) {
        // Add optional payment brand/label to expenses table
        if (!await _hasColumn('expenses_table', 'payment_method_brand')) {
          await m.addColumn(expensesTable, expensesTable.paymentMethodBrand);
        }
        if (!await _hasColumn('expenses_table', 'payment_method_label')) {
          await m.addColumn(expensesTable, expensesTable.paymentMethodLabel);
        }
      }
    },
  );

  // Trips Operations
  Future<List<TripsTableData>> getAllTrips() => select(tripsTable).get();
  
  Stream<List<TripsTableData>> watchAllTrips() => select(tripsTable).watch();

  Future<void> insertTrip(TripsTableCompanion trip) {
    return into(tripsTable).insert(trip);
  }

  Future<void> updateTrip(TripsTableData trip) {
    return update(tripsTable).replace(trip);
  }

  Future<void> deleteTrip(String tripId) {
    return (delete(tripsTable)..where((t) => t.id.equals(tripId))).go();
  }

  Future<void> deleteExpensesByTrip(String tripId) {
    return (delete(expensesTable)..where((e) => e.tripId.equals(tripId))).go();
  }

  Future<void> deleteReceiptsByTrip(String tripId) async {
    // First delete all receipts for expenses in this trip
    final expenses = await (select(expensesTable)..where((e) => e.tripId.equals(tripId))).get();
    for (final expense in expenses) {
      await (delete(receiptsTable)..where((r) => r.expenseId.equals(expense.id))).go();
    }
  }

  // Expenses Operations
  Future<List<ExpensesTableData>> getExpensesByTrip(String tripId) {
    return (select(expensesTable)..where((e) => e.tripId.equals(tripId))).get();
  }

  Stream<List<ExpensesTableData>> watchExpensesByTrip(String tripId) {
    return (select(expensesTable)..where((e) => e.tripId.equals(tripId))).watch();
  }

  Future<void> insertExpense(ExpensesTableCompanion expense) {
    return into(expensesTable).insert(expense);
  }

  Future<void> updateExpense(ExpensesTableData expense) {
    return update(expensesTable).replace(expense);
  }

  Future<void> deleteExpense(String expenseId) {
    return (delete(expensesTable)..where((e) => e.id.equals(expenseId))).go();
  }

  // Receipts Operations
  Future<List<ReceiptsTableData>> getReceiptsByExpense(String expenseId) {
    return (select(receiptsTable)..where((r) => r.expenseId.equals(expenseId))).get();
  }

  Stream<List<ReceiptsTableData>> watchReceiptsByExpense(String expenseId) {
    return (select(receiptsTable)..where((r) => r.expenseId.equals(expenseId))).watch();
  }

  Future<void> insertReceipt(ReceiptsTableCompanion receipt) {
    return into(receiptsTable).insert(receipt);
  }

  Future<void> deleteReceipt(String receiptId) {
    return (delete(receiptsTable)..where((r) => r.id.equals(receiptId))).go();
  }

  /// Cascading delete: trip + all its expenses + all receipts
  Future<void> deleteTripCascade(String tripId) async {
    await deleteReceiptsByTrip(tripId);
    await deleteExpensesByTrip(tripId);
    await deleteTrip(tripId);
  }
}
