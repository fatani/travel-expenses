import 'package:travel_expenses/core/models/expense.dart';
import 'package:travel_expenses/core/models/receipt.dart';
import 'package:travel_expenses/core/models/trip.dart';

abstract class AppRepository {
  // Trips
  Future<List<Trip>> getAllTrips();
  Stream<List<Trip>> watchAllTrips();
  Future<void> insertTrip(Trip trip);
  Future<void> updateTrip(Trip trip);
  Future<void> deleteTrip(String tripId);

  // Expenses
  Future<List<Expense>> getExpensesByTrip(String tripId);
  Stream<List<Expense>> watchExpensesByTrip(String tripId);
  Future<void> insertExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String expenseId);

  // Receipts
  Future<List<Receipt>> getReceiptsByExpense(String expenseId);
  Stream<List<Receipt>> watchReceiptsByExpense(String expenseId);
  Future<void> insertReceipt(Receipt receipt);
  Future<void> deleteReceipt(String receiptId);
}
