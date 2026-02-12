import 'package:drift/drift.dart';
import 'package:travel_expenses/core/models/expense.dart';
import 'package:travel_expenses/core/models/receipt.dart';
import 'package:travel_expenses/core/models/trip.dart';

import 'app_database.dart';
import 'app_repository.dart';

/// Repository implementation using Drift database
/// Maps Drift data types to domain models (Trip, Expense, Receipt)
class DriftRepository implements AppRepository {
  final AppDatabase _db;

  DriftRepository(this._db);

  // ============== Trips ==============

  @override
  Future<List<Trip>> getAllTrips() async {
    final records = await _db.getAllTrips();
    return records.map(_rowToTrip).toList();
  }

  @override
  Stream<List<Trip>> watchAllTrips() {
    return _db.watchAllTrips().map(
      (records) => records.map(_rowToTrip).toList(),
    );
  }

  @override
  Future<void> insertTrip(Trip trip) async {
    final companion = TripsTableCompanion(
      id: Value(trip.id),
      name: Value(trip.name),
      defaultCurrency: Value(trip.defaultCurrency),
      startDate: Value(trip.startDate),
      endDate: Value(trip.endDate),
      createdAt: Value(trip.createdAt),
    );
    await _db.insertTrip(companion);
  }

  @override
  Future<void> updateTrip(Trip trip) async {
    final record = TripsTableData(
      id: trip.id,
      name: trip.name,
      defaultCurrency: trip.defaultCurrency,
      startDate: trip.startDate,
      endDate: trip.endDate,
      createdAt: trip.createdAt,
    );
    await _db.updateTrip(record);
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    // Cascade delete: trip + expenses + receipts
    await _db.deleteTripCascade(tripId);
  }

  // ============== Expenses ==============

  @override
  Future<List<Expense>> getExpensesByTrip(String tripId) async {
    final records = await _db.getExpensesByTrip(tripId);
    return records.map(_rowToExpense).toList();
  }

  @override
  Stream<List<Expense>> watchExpensesByTrip(String tripId) {
    return _db.watchExpensesByTrip(tripId).map(
      (records) => records.map(_rowToExpense).toList(),
    );
  }

  @override
  Future<void> insertExpense(Expense expense) async {
    final companion = ExpensesTableCompanion(
      id: Value(expense.id),
      tripId: Value(expense.tripId),
      amount: Value(expense.amount),
      currency: Value(expense.currency),
      date: Value(expense.date),
      category: Value(expense.category),
      note: Value(expense.note),
      createdAt: Value(expense.createdAt),
    );
    await _db.insertExpense(companion);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final record = ExpensesTableData(
      id: expense.id,
      tripId: expense.tripId,
      amount: expense.amount,
      currency: expense.currency,
      date: expense.date,
      category: expense.category,
      note: expense.note,
      createdAt: expense.createdAt,
    );
    await _db.updateExpense(record);
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    // Delete receipts first (foreign key constraint)
    final records = await _db.getReceiptsByExpense(expenseId);
    for (final receipt in records) {
      await _db.deleteReceipt(receipt.id);
    }
    // Then delete expense
    await _db.deleteExpense(expenseId);
  }

  // ============== Receipts ==============

  @override
  Future<List<Receipt>> getReceiptsByExpense(String expenseId) async {
    final records = await _db.getReceiptsByExpense(expenseId);
    return records.map(_rowToReceipt).toList();
  }

  @override
  Stream<List<Receipt>> watchReceiptsByExpense(String expenseId) {
    return _db.watchReceiptsByExpense(expenseId).map(
      (records) => records.map(_rowToReceipt).toList(),
    );
  }

  @override
  Future<void> insertReceipt(Receipt receipt) async {
    final companion = ReceiptsTableCompanion(
      id: Value(receipt.id),
      expenseId: Value(receipt.expenseId),
      localPath: Value(receipt.localPath),
      createdAt: Value(receipt.createdAt),
    );
    await _db.insertReceipt(companion);
  }

  @override
  Future<void> deleteReceipt(String receiptId) async {
    await _db.deleteReceipt(receiptId);
  }

  // ============== Mappers ==============

  Trip _rowToTrip(TripsTableData row) {
    return Trip(
      id: row.id,
      name: row.name,
      defaultCurrency: row.defaultCurrency,
      startDate: row.startDate,
      endDate: row.endDate,
      createdAt: row.createdAt,
    );
  }

  Expense _rowToExpense(ExpensesTableData row) {
    return Expense(
      id: row.id,
      tripId: row.tripId,
      amount: row.amount,
      currency: row.currency,
      date: row.date,
      category: row.category,
      note: row.note,
      createdAt: row.createdAt,
    );
  }

  Receipt _rowToReceipt(ReceiptsTableData row) {
    return Receipt(
      id: row.id,
      expenseId: row.expenseId,
      localPath: row.localPath,
      createdAt: row.createdAt,
    );
  }
}
