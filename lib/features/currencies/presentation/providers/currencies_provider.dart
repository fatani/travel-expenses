import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/db/db_providers.dart';

// Get all currencies as a stream
final currenciesProvider = StreamProvider<List<CurrenciesTableData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.watchAllCurrencies();
});

// Add a new currency
final addCurrencyProvider = StateNotifierProvider<AddCurrencyNotifier, AsyncValue<void>>(
  (ref) => AddCurrencyNotifier(ref),
);

class AddCurrencyNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  AddCurrencyNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> addCurrency({
    required String code,
    required String name,
    required String? symbol,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Validate code
      final upperCode = code.toUpperCase().trim();
      if (upperCode.isEmpty || upperCode.length < 2 || upperCode.length > 5) {
        state = AsyncValue.error(
          'رمز العملة يجب أن يكون بين 2 و 5 أحرف',
          StackTrace.current,
        );
        return;
      }

      // Check if code exists
      final db = ref.read(appDatabaseProvider);
      final exists = await db.currencyCodeExists(upperCode);
      if (exists) {
        state = AsyncValue.error(
          'رمز العملة "$upperCode" مستخدم مسبقًا',
          StackTrace.current,
        );
        return;
      }

      // Validate name
      if (name.trim().isEmpty) {
        state = AsyncValue.error(
          'اسم العملة مطلوب',
          StackTrace.current,
        );
        return;
      }

      // Insert currency
      await db.insertCurrency(
        CurrenciesTableCompanion(
          id: Value('${upperCode}_${DateTime.now().millisecondsSinceEpoch}'),
          code: Value(upperCode),
          name: Value(name.trim()),
          symbol: Value(symbol?.trim().isEmpty == true ? null : symbol?.trim()),
          createdAt: Value(DateTime.now()),
        ),
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint('[ERR][currencies][add]: $e');
      state = AsyncValue.error(
        'فشل إضافة العملة. حاول مرة أخرى.',
        st,
      );
    }
  }
}
