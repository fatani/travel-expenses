import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travel_expenses/core/models/expense.dart';
import 'package:travel_expenses/features/expenses/presentation/pages/expense_list_page.dart';
import 'package:travel_expenses/features/expenses/presentation/providers/expense_filters_provider.dart';
import 'package:travel_expenses/features/expenses/presentation/providers/expenses_providers.dart';

void main() {
  group('ExpenseListPage - Empty and No-Match States', () {
    // Test data
    const tripId = 'test-trip-1';
    const tripCurrency = 'USD';

    final testExpense1 = Expense(
      id: 'expense-1',
      tripId: tripId,
      amount: 50.0,
      currency: 'USD',
      date: DateTime(2026, 2, 1, 12, 0),
      category: 'الطعام',
      note: 'Lunch at restaurant',
      merchant: 'Restaurant A',
      paymentMethod: 'cash',
      createdAt: DateTime(2026, 2, 1, 12, 0),
    );

    final testExpense2 = Expense(
      id: 'expense-2',
      tripId: tripId,
      amount: 25.0,
      currency: 'USD',
      date: DateTime(2026, 2, 2, 14, 30),
      category: 'المواصلات',
      note: 'Taxi ride downtown',
      merchant: 'Taxi Service',
      paymentMethod: 'card',
      createdAt: DateTime(2026, 2, 2, 14, 30),
    );

    testWidgets('Empty state: shows "لا توجد مصاريف" when no expenses',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchExpensesByTripProvider(tripId).overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ExpenseListPage(
                tripId: tripId,
                tripCurrency: tripCurrency,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify empty state message appears
      expect(find.text('لا توجد مصاريف'), findsOneWidget);
      expect(find.text('أضف أول مصروف لهذه الرحلة.'), findsOneWidget);
    });

    testWidgets(
        'No-match state: shows "لا توجد نتائج مطابقة" when filters hide results',
        (WidgetTester tester) async {
      // Create a container to manage provider state and set initial filter
      final container = ProviderContainer(
        overrides: [
          watchExpensesByTripProvider(tripId).overrideWith(
            (ref) => Stream.value([testExpense1, testExpense2]),
          ),
        ],
      );

      // Set filter to a query that matches nothing
      container.read(expenseFiltersProvider(tripId).notifier).setQuery('zzz');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: ExpenseListPage(
                tripId: tripId,
                tripCurrency: tripCurrency,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no-match message appears
      expect(find.text('لا توجد نتائج مطابقة'), findsOneWidget);
      expect(find.text('إعادة ضبط'), findsOneWidget);

      // Verify base expenses are not shown
      expect(find.text('Restaurant A'), findsNothing);
      expect(find.text('Taxi Service'), findsNothing);
    });

    testWidgets(
        'Reset button: clears filters and shows expenses when clicked',
        (WidgetTester tester) async {
      // Create a container to manage provider state
      final container = ProviderContainer(
        overrides: [
          watchExpensesByTripProvider(tripId).overrideWith(
            (ref) => Stream.value([testExpense1, testExpense2]),
          ),
        ],
      );

      // Start with a no-match query
      container.read(expenseFiltersProvider(tripId).notifier).setQuery('zzz');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: ExpenseListPage(
                tripId: tripId,
                tripCurrency: tripCurrency,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no-match state initially
      expect(find.text('لا توجد نتائج مطابقة'), findsOneWidget);
      expect(find.text('Restaurant A'), findsNothing);

      // Find and tap the reset button
      final resetButton = find.text('إعادة ضبط');
      expect(resetButton, findsOneWidget);

      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Verify no-match message is gone
      expect(find.text('لا توجد نتائج مطابقة'), findsNothing);

      // Verify expenses now appear
      expect(find.text('Restaurant A'), findsWidgets);
      expect(find.text('Taxi Service'), findsWidgets);
    });

    testWidgets(
        'Shows merchant names in list when expenses are visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchExpensesByTripProvider(tripId).overrideWith(
              (ref) => Stream.value([testExpense1, testExpense2]),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ExpenseListPage(
                tripId: tripId,
                tripCurrency: tripCurrency,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify both merchants appear in list
      expect(find.text('Restaurant A'), findsOneWidget);
      expect(find.text('Taxi Service'), findsOneWidget);
    });

  });
}
