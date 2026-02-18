import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/currencies_provider.dart';
import 'add_currency_bottom_sheet.dart';

class CurrencyDropdown extends ConsumerWidget {
  final String? selectedCurrency;
  final ValueChanged<String?> onChanged;
  final String labelText;
  final String? helperText;
  final bool isRequired;

  const CurrencyDropdown({
    super.key,
    this.selectedCurrency,
    required this.onChanged,
    this.labelText = 'اختر العملة',
    this.helperText,
    this.isRequired = true,
  });

  void _showAddCurrencySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => AddCurrencyBottomSheet(
        onCurrencyAdded: (code) {
          if (code != null) {
            onChanged(code);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currenciesAsync = ref.watch(currenciesProvider);

    return currenciesAsync.when(
      data: (currencies) {
        // Sort currencies: default first (SAR, USD, EUR), then custom
        final defaultCodes = ['SAR', 'USD', 'EUR'];
        final sortedCurrencies = currencies
          ..sort((a, b) {
            final aIndex = defaultCodes.indexOf(a.code);
            final bIndex = defaultCodes.indexOf(b.code);
            if (aIndex != -1 && bIndex != -1) {
              return aIndex.compareTo(bIndex);
            }
            if (aIndex != -1) return -1;
            if (bIndex != -1) return 1;
            return a.code.compareTo(b.code);
          });

        return DropdownButtonFormField<String>(
          value: selectedCurrency,
          decoration: InputDecoration(
            labelText: labelText,
            helperText: helperText,
            border: const OutlineInputBorder(),
          ),
          items: [
            // Regular currencies
            ...sortedCurrencies.map((currency) {
              return DropdownMenuItem<String>(
                value: currency.code,
                child: Text('${currency.code} (${currency.name})'),
              );
            }).toList(),
            // Divider
            if (sortedCurrencies.isNotEmpty)
              DropdownMenuItem<String>(
                enabled: false,
                child: Divider(height: 16),
              ),
            // Add new currency option
            DropdownMenuItem<String>(
              enabled: true,
              value: '_ADD_NEW_',
              child: const Text('➕ إضافة عملة جديدة'),
            ),
          ],
          onChanged: (value) {
            if (value == '_ADD_NEW_') {
              _showAddCurrencySheet(context, ref);
              return;
            }

            if (value != null) {
              onChanged(value);
            }
          },
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'اختر العملة';
                  }
                  return null;
                }
              : null,
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('خطأ في تحميل العملات: $error'),
      ),
    );
  }
}
