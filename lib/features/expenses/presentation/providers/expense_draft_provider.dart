import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense_draft.dart';

class ExpenseDraftNotifier extends StateNotifier<ExpenseDraft> {
  ExpenseDraftNotifier() : super(const ExpenseDraft());

  void set(ExpenseDraft next) {
    state = next;
  }

  void patch({
    String? amountText,
    String? currencyCode,
    String? categoryId,
    DateTime? date,
    String? merchant,
    String? paymentMethodType,
    String? paymentBrand,
    String? paymentLabel,
    String? locationText,
    String? notes,
    bool? hasReceipts,
  }) {
    state = state.copyWith(
      amountText: amountText,
      currencyCode: currencyCode,
      categoryId: categoryId,
      date: date,
      merchant: merchant,
      paymentMethodType: paymentMethodType,
      paymentBrand: paymentBrand,
      paymentLabel: paymentLabel,
      locationText: locationText,
      notes: notes,
      hasReceipts: hasReceipts ?? state.hasReceipts,
    );
  }

  void clear() {
    state = const ExpenseDraft();
  }
}

final expenseDraftProvider =
    StateNotifierProvider.family<ExpenseDraftNotifier, ExpenseDraft, String>(
  (ref, _) => ExpenseDraftNotifier(),
);
