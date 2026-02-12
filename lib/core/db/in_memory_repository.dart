import 'dart:async';

import 'package:travel_expenses/core/db/app_repository.dart';
import 'package:travel_expenses/core/models/expense.dart';
import 'package:travel_expenses/core/models/receipt.dart';
import 'package:travel_expenses/core/models/trip.dart';

class InMemoryRepository implements AppRepository {
  final List<Trip> _trips = [];
  final List<Expense> _expenses = [];
  final List<Receipt> _receipts = [];

  final tripsController = StreamController<List<Trip>>.broadcast();
  final expensesController = StreamController<List<Expense>>.broadcast();
  final receiptsController = StreamController<List<Receipt>>.broadcast();

  @override
  Future<List<Trip>> getAllTrips() async => List.from(_trips);

  @override
  Stream<List<Trip>> watchAllTrips() {
    tripsController.add(List.from(_trips));
    return tripsController.stream;
  }

  @override
  Future<void> insertTrip(Trip trip) async {
    _trips.add(trip);
    tripsController.add(List.from(_trips));
  }

  @override
  Future<void> updateTrip(Trip trip) async {
    final index = _trips.indexWhere((t) => t.id == trip.id);
    if (index >= 0) {
      _trips[index] = trip;
      tripsController.add(List.from(_trips));
    }
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    _trips.removeWhere((t) => t.id == tripId);
    _expenses.removeWhere((e) => e.tripId == tripId);
    tripsController.add(List.from(_trips));
  }

  @override
  Future<List<Expense>> getExpensesByTrip(String tripId) async {
    return _expenses.where((e) => e.tripId == tripId).toList();
  }

  @override
  Stream<List<Expense>> watchExpensesByTrip(String tripId) {
    final filtered = _expenses.where((e) => e.tripId == tripId).toList();
    expensesController.add(filtered);
    return expensesController.stream.map((e) => e.where((x) => x.tripId == tripId).toList());
  }

  @override
  Future<void> insertExpense(Expense expense) async {
    _expenses.add(expense);
    expensesController.add(List.from(_expenses));
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index >= 0) {
      _expenses[index] = expense;
      expensesController.add(List.from(_expenses));
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    _expenses.removeWhere((e) => e.id == expenseId);
    _receipts.removeWhere((r) => r.expenseId == expenseId);
    expensesController.add(List.from(_expenses));
  }

  @override
  Future<List<Receipt>> getReceiptsByExpense(String expenseId) async {
    return _receipts.where((r) => r.expenseId == expenseId).toList();
  }

  @override
  Stream<List<Receipt>> watchReceiptsByExpense(String expenseId) {
    final filtered = _receipts.where((r) => r.expenseId == expenseId).toList();
    receiptsController.add(filtered);
    return receiptsController.stream.map((r) => r.where((x) => x.expenseId == expenseId).toList());
  }

  @override
  Future<void> insertReceipt(Receipt receipt) async {
    _receipts.add(receipt);
    receiptsController.add(List.from(_receipts));
  }

  @override
  Future<void> deleteReceipt(String receiptId) async {
    _receipts.removeWhere((r) => r.id == receiptId);
    receiptsController.add(List.from(_receipts));
  }

  void dispose() {
    tripsController.close();
    expensesController.close();
    receiptsController.close();
  }
}
