import 'dart:convert';
import 'dart:typed_data';

import '../../../core/models/trip.dart';
import '../../../core/models/expense.dart';

class CsvExportService {
  /// Escape a CSV field properly (RFC 4180 compliant)
  static String _escapeCsvField(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }

    // If field contains comma, quote, or newline, wrap in quotes and escape internal quotes
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }

    return value;
  }

  /// Build CSV header row
  static const String csvHeader =
      'date,amount,currency,category,merchant,payment_type,payment_brand,payment_label,location_text,notes,has_receipts,receipts_count';

  /// Build a single CSV row from an expense
  static String _buildExpenseRow(
    Expense expense,
    int receiptsCount,
  ) {
    final dateStr =
        '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';
    final amountStr = expense.amount.toStringAsFixed(2);
    final categoryStr = expense.category;
    final merchantStr = _escapeCsvField(expense.merchant);
    final paymentTypeStr = _escapeCsvField(expense.paymentMethod);
    final paymentBrandStr = _escapeCsvField(expense.paymentMethodBrand);
    final paymentLabelStr = _escapeCsvField(expense.paymentMethodLabel);
    final locationStr = _escapeCsvField(expense.locationText);
    final notesStr = _escapeCsvField(expense.note);
    final hasReceiptsStr = receiptsCount > 0 ? 'true' : 'false';

    return '$dateStr,$amountStr,${expense.currency},$categoryStr,$merchantStr,$paymentTypeStr,$paymentBrandStr,$paymentLabelStr,$locationStr,$notesStr,$hasReceiptsStr,$receiptsCount';
  }

  /// Build complete CSV string for trip expenses
  String buildTripExpensesCsv({
    required Trip trip,
    required List<Expense> expenses,
    required Map<String, int> receiptsCountByExpenseId,
  }) {
    final lines = <String>[csvHeader];

    for (final expense in expenses) {
      final receiptsCount = receiptsCountByExpenseId[expense.id] ?? 0;
      final row = _buildExpenseRow(expense, receiptsCount);
      lines.add(row);
    }

    return lines.join('\n');
  }

  /// Build CSV bytes (UTF-8 encoded)
  Uint8List buildTripExpensesCsvBytes({
    required Trip trip,
    required List<Expense> expenses,
    required Map<String, int> receiptsCountByExpenseId,
  }) {
    final csv = buildTripExpensesCsv(
      trip: trip,
      expenses: expenses,
      receiptsCountByExpenseId: receiptsCountByExpenseId,
    );
    return Uint8List.fromList(utf8.encode(csv));
  }

  /// Generate a sanitized filename for the CSV export
  static String generateExportFilename(Trip trip) {
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    // Sanitize trip name: replace spaces with underscore, remove special chars
    final sanitizedName = trip.name
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '')
        .toLowerCase();

    return 'trip_expenses_${sanitizedName}_$dateStr.csv';
  }
}
