import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class OcrSuggestion {
  final double? amount;
  final String? merchant;
  final String? locationText;
  final DateTime? date;
  final String? currencyCode;
  final String? notes;

  const OcrSuggestion({
    this.amount,
    this.merchant,
    this.locationText,
    this.date,
    this.currencyCode,
    this.notes,
  });

  bool get hasAnyValue {
    return amount != null ||
        merchant != null ||
        locationText != null ||
        date != null ||
        currencyCode != null ||
        notes != null;
  }
}

class OcrSuggestionNotifier extends StateNotifier<AsyncValue<OcrSuggestion?>> {
  OcrSuggestionNotifier() : super(const AsyncValue.data(null));

  Future<void> generate({
    required String tripId,
    required String draftKey,
    required int receiptsCount,
    required int seed,
    String? currentCurrencyCode,
    String? currentMerchant,
    String? currentLocationText,
    DateTime? currentDate,
    double? currentAmount,
  }) async {
    assert(tripId.isNotEmpty || draftKey.isNotEmpty);

    if (receiptsCount == 0) {
      state = AsyncValue.error(
        'اختر إيصالاً أولاً.',
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));

      final amounts = <double>[
        12,
        18,
        20,
        30,
        45,
        55,
        66,
        88,
        120,
        148,
        218,
        300,
        520,
      ];
      final merchants = <String>[
        'Starbucks',
        'Uber',
        'Hotel ABC',
        'مطعم البيك',
        'Carrefour',
        'AlBaik',
        'Marriott',
        'رامادا',
      ];
      final locations = <String>[
        'Taksim',
        'Doha Airport',
        'مطار الدوحة',
        'Istanbul',
        'الدوحة',
        '—',
      ];

      final amount = amounts[seed % amounts.length];
      final merchant = merchants[(seed ~/ 7) % merchants.length];
      final locationText = locations[(seed ~/ 13) % locations.length];
      final date = currentDate ??
          DateTime.now().subtract(Duration(days: seed % 6));
      final currencyCode = currentCurrencyCode ?? 'SAR';

      final suggestion = OcrSuggestion(
        amount: currentAmount != null ? null : amount,
        merchant:
            (currentMerchant?.trim().isNotEmpty ?? false) ? null : merchant,
        locationText:
            (currentLocationText?.trim().isNotEmpty ?? false) ? null : locationText,
        date: currentDate != null ? null : date,
        currencyCode:
            (currentCurrencyCode?.trim().isNotEmpty ?? false) ? null : currencyCode,
        notes: null,
      );

      state = AsyncValue.data(suggestion);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final ocrSuggestionProvider = StateNotifierProvider.autoDispose
    .family<OcrSuggestionNotifier, AsyncValue<OcrSuggestion?>, String>(
  (ref, _) => OcrSuggestionNotifier(),
);
