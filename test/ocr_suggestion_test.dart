import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travel_expenses/features/expenses/presentation/providers/ocr_suggestion_provider.dart';

void main() {
  group('OcrSuggestionProvider', () {
    test('same seed yields same amount and merchant', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const draftKey = 'draft-1';
      final subscription = container.listen(
        ocrSuggestionProvider(draftKey),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final notifier =
          container.read(ocrSuggestionProvider(draftKey).notifier);

      await notifier.generate(
        tripId: 'trip-1',
        draftKey: draftKey,
        receiptsCount: 1,
        seed: 12345,
        currentCurrencyCode: null,
        currentMerchant: null,
        currentLocationText: null,
        currentDate: null,
        currentAmount: null,
      );

      final first = container.read(ocrSuggestionProvider(draftKey)).value;

      await notifier.generate(
        tripId: 'trip-1',
        draftKey: draftKey,
        receiptsCount: 1,
        seed: 12345,
        currentCurrencyCode: null,
        currentMerchant: null,
        currentLocationText: null,
        currentDate: null,
        currentAmount: null,
      );

      final second = container.read(ocrSuggestionProvider(draftKey)).value;

      expect(first?.amount, second?.amount);
      expect(first?.merchant, second?.merchant);
    });

    test('current merchant keeps suggestion empty', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const draftKey = 'draft-2';
      final subscription = container.listen(
        ocrSuggestionProvider(draftKey),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final notifier =
          container.read(ocrSuggestionProvider(draftKey).notifier);

      await notifier.generate(
        tripId: 'trip-1',
        draftKey: draftKey,
        receiptsCount: 1,
        seed: 7,
        currentCurrencyCode: null,
        currentMerchant: 'Existing',
        currentLocationText: null,
        currentDate: null,
        currentAmount: null,
      );

      final suggestion = container.read(ocrSuggestionProvider(draftKey)).value;
      expect(suggestion?.merchant, isNull);
    });

    test('receiptsCount == 0 returns error', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const draftKey = 'draft-3';
      final subscription = container.listen(
        ocrSuggestionProvider(draftKey),
        (_, __) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final notifier =
          container.read(ocrSuggestionProvider(draftKey).notifier);

      await notifier.generate(
        tripId: 'trip-1',
        draftKey: draftKey,
        receiptsCount: 0,
        seed: 1,
        currentCurrencyCode: null,
        currentMerchant: null,
        currentLocationText: null,
        currentDate: null,
        currentAmount: null,
      );

      final state = container.read(ocrSuggestionProvider(draftKey));
      expect(state.hasError, isTrue);
      expect(state.error, 'اختر إيصالاً أولاً.');
    });
  });
}
