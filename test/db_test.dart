import 'package:flutter_test/flutter_test.dart';
import 'package:travel_expenses/core/db/in_memory_repository.dart';
import 'package:travel_expenses/core/models/expense.dart';
import 'package:travel_expenses/core/models/receipt.dart';
import 'package:travel_expenses/core/models/trip.dart';

void main() {
  group('InMemory Database CRUD Tests', () {
    late InMemoryRepository repo;

    setUp(() {
      repo = InMemoryRepository();
    });

    tearDown(() {
      repo.dispose();
    });

    test('Insert and retrieve trip', () async {
      final trip = Trip(
        id: 'trip-001',
        name: 'Test Trip',
        defaultCurrency: 'SAR',
        createdAt: DateTime.now(),
      );

      await repo.insertTrip(trip);
      final trips = await repo.getAllTrips();

      expect(trips.length, 1);
      expect(trips.first.name, 'Test Trip');
    });

    test('Insert expense linked to trip', () async {
      final trip = Trip(
        id: 'trip-002',
        name: 'Expense Test Trip',
        defaultCurrency: 'USD',
        createdAt: DateTime.now(),
      );
      await repo.insertTrip(trip);

      final expense = Expense(
        id: 'exp-001',
        tripId: 'trip-002',
        amount: 50.0,
        currency: 'USD',
        date: DateTime.now(),
        category: 'Food',
        merchant: 'Test Restaurant',
        paymentMethod: 'cash',
        locationText: 'Test Location',
        createdAt: DateTime.now(),
      );

      await repo.insertExpense(expense);
      final expenses = await repo.getExpensesByTrip('trip-002');

      expect(expenses.length, 1);
      expect(expenses.first.amount, 50.0);
    });

    test('Insert receipt linked to expense', () async {
      final trip = Trip(
        id: 'trip-003',
        name: 'Receipt Test Trip',
        defaultCurrency: 'SAR',
        createdAt: DateTime.now(),
      );
      await repo.insertTrip(trip);

      final expense = Expense(
        id: 'exp-002',
        tripId: 'trip-003',
        amount: 100.0,
        currency: 'SAR',
        date: DateTime.now(),
        category: 'Transport',
        merchant: 'Uber',
        paymentMethod: 'card',
        createdAt: DateTime.now(),
      );
      await repo.insertExpense(expense);

      final receipt = Receipt(
        id: 'receipt-001',
        expenseId: 'exp-002',
        localPath: '/path/to/receipt.png',
        createdAt: DateTime.now(),
      );

      await repo.insertReceipt(receipt);
      final receipts = await repo.getReceiptsByExpense('exp-002');

      expect(receipts.length, 1);
      expect(receipts.first.localPath, '/path/to/receipt.png');
    });

    test('Delete expense cascades to receipt', () async {
      final trip = Trip(
        id: 'trip-004',
        name: 'Cascade Test Trip',
        defaultCurrency: 'SAR',
        createdAt: DateTime.now(),
      );
      await repo.insertTrip(trip);

      final expense = Expense(
        id: 'exp-003',
        tripId: 'trip-004',
        amount: 75.0,
        currency: 'SAR',
        date: DateTime.now(),
        category: 'Lodging',
        merchant: 'Hotel ABC',
        paymentMethod: 'card',
        createdAt: DateTime.now(),
      );
      await repo.insertExpense(expense);

      final receipt = Receipt(
        id: 'receipt-002',
        expenseId: 'exp-003',
        localPath: '/path/to/receipt2.png',
        createdAt: DateTime.now(),
      );
      await repo.insertReceipt(receipt);

      // Delete expense
      await repo.deleteExpense('exp-003');

      // Check receipts are deleted too
      final remainingReceipts = await repo.getReceiptsByExpense('exp-003');
      expect(remainingReceipts.length, 0);
    });
  });
}

