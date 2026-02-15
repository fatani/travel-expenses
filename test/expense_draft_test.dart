import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travel_expenses/features/expenses/presentation/models/expense_draft.dart';
import 'package:travel_expenses/features/expenses/presentation/providers/expense_draft_provider.dart';

void main() {
  test('Draft per trip is isolated', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(expenseDraftProvider('trip-a').notifier).set(
          const ExpenseDraft(amountText: '10', merchant: 'A'),
        );
    container.read(expenseDraftProvider('trip-b').notifier).set(
          const ExpenseDraft(amountText: '20', merchant: 'B'),
        );

    expect(container.read(expenseDraftProvider('trip-a')).amountText, '10');
    expect(container.read(expenseDraftProvider('trip-b')).amountText, '20');
  });

  test('Clear on save empties draft', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(expenseDraftProvider('trip-c').notifier);
    notifier.set(const ExpenseDraft(amountText: '33', merchant: 'Cafe'));
    notifier.clear();

    expect(container.read(expenseDraftProvider('trip-c')).isEmpty, isTrue);
  });

  test('isEmpty reflects fields and receipts', () {
    const emptyDraft = ExpenseDraft();
    const amountDraft = ExpenseDraft(amountText: '12');
    const receiptDraft = ExpenseDraft(hasReceipts: true);

    expect(emptyDraft.isEmpty, isTrue);
    expect(amountDraft.isEmpty, isFalse);
    expect(receiptDraft.isEmpty, isFalse);
  });
}
