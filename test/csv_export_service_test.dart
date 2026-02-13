import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:travel_expenses/core/models/expense.dart';
import 'package:travel_expenses/core/models/trip.dart';
import 'package:travel_expenses/features/export/services/csv_export_service.dart';

Trip _createTrip({
  required String name,
  required String id,
}) {
  return Trip(
    id: id,
    name: name,
    startDate: DateTime(2026, 1, 10),
    endDate: DateTime(2026, 1, 15),
    defaultCurrency: 'USD',
    createdAt: DateTime(2026, 1, 10),
  );
}

Expense _expense({
  required String id,
  required double amount,
  required String currency,
  required String category,
  required String merchant,
  required String paymentMethod,
  String? paymentMethodBrand,
  String? paymentMethodLabel,
  String? locationText,
  String? note,
}) {
  return Expense(
    id: id,
    tripId: 'trip1',
    amount: amount,
    currency: currency,
    date: DateTime(2026, 1, 10, 14, 30),
    category: category,
    note: note,
    merchant: merchant,
    paymentMethod: paymentMethod,
    paymentMethodBrand: paymentMethodBrand,
    paymentMethodLabel: paymentMethodLabel,
    locationText: locationText,
    createdAt: DateTime(2026, 1, 10, 15, 0),
  );
}

void main() {
  final service = CsvExportService();

  test('CSV header is correct', () {
    final csv = service.buildTripExpensesCsv(
      trip: _createTrip(name: 'Test Trip', id: 'trip1'),
      expenses: [],
      receiptsCountByExpenseId: {},
    );

    expect(
      csv.startsWith(
          'date,amount,currency,category,merchant,payment_type,payment_brand,payment_label,location_text,notes,has_receipts,receipts_count'),
      true,
    );
  });

  test('CSV escaping works for comma in merchant', () {
    final expenses = [
      _expense(
        id: '1',
        amount: 50.5,
        currency: 'USD',
        category: 'الطعام',
        merchant: 'Restaurant, Inc.',
        paymentMethod: 'cash',
      ),
    ];

    final csv = service.buildTripExpensesCsv(
      trip: _createTrip(name: 'Test Trip', id: 'trip1'),
      expenses: expenses,
      receiptsCountByExpenseId: {},
    );

    expect(csv.contains('"Restaurant, Inc."'), true);
  });

  test('CSV escaping works for quote in text', () {
    final expenses = [
      _expense(
        id: '1',
        amount: 25.0,
        currency: 'USD',
        category: 'الطعام',
        merchant: 'Restaurant',
        paymentMethod: 'cash',
        note: 'Got a "special" deal',
      ),
    ];

    final csv = service.buildTripExpensesCsv(
      trip: _createTrip(name: 'Test Trip', id: 'trip1'),
      expenses: expenses,
      receiptsCountByExpenseId: {},
    );

    // Quote should be escaped as ""
    expect(csv.contains('Got a ""special"" deal'), true);
  });

  test('CSV escaping works for newline in text', () {
    final expenses = [
      _expense(
        id: '1',
        amount: 100.0,
        currency: 'USD',
        category: 'الطعام',
        merchant: 'Restaurant',
        paymentMethod: 'card',
        note: 'Line 1\nLine 2',
      ),
    ];

    final csv = service.buildTripExpensesCsv(
      trip: _createTrip(name: 'Test Trip', id: 'trip1'),
      expenses: expenses,
      receiptsCountByExpenseId: {},
    );

    // Newline should be quoted: "Line 1\nLine 2"
    expect(csv.contains('"Line 1\nLine 2"'), true);
  });

  test('Amount formatting is correct (2 decimals)', () {
    final expenses = [
      _expense(
        id: '1',
        amount: 50.5,
        currency: 'USD',
        category: 'الطعام',
        merchant: 'Restaurant',
        paymentMethod: 'cash',
      ),
      _expense(
        id: '2',
        amount: 100.0,
        currency: 'USD',
        category: 'المواصلات',
        merchant: 'Uber',
        paymentMethod: 'card',
      ),
    ];

    final csv = service.buildTripExpensesCsv(
      trip: _createTrip(name: 'Test Trip', id: 'trip1'),
      expenses: expenses,
      receiptsCountByExpenseId: {},
    );

    expect(csv.contains('50.50'), true);
    expect(csv.contains('100.00'), true);
  });

  test('has_receipts and receipts_count are correct', () {
    final expenses = [
      _expense(
        id: '1',
        amount: 50.0,
        currency: 'USD',
        category: 'الطعام',
        merchant: 'Restaurant',
        paymentMethod: 'cash',
      ),
      _expense(
        id: '2',
        amount: 100.0,
        currency: 'USD',
        category: 'المواصلات',
        merchant: 'Uber',
        paymentMethod: 'card',
      ),
    ];

    final csv = service.buildTripExpensesCsv(
      trip: _createTrip(name: 'Test Trip', id: 'trip1'),
      expenses: expenses,
      receiptsCountByExpenseId: {
        '1': 2,
        '2': 0,
      },
    );

    final lines = csv.split('\n');
    expect(lines[1].endsWith('true,2'), true); // expense 1 has 2 receipts
    expect(lines[2].endsWith('false,0'), true); // expense 2 has 0 receipts
  });

  test('CSV bytes are UTF-8 encoded', () {
    final expenses = [
      _expense(
        id: '1',
        amount: 50.0,
        currency: 'USD',
        category: 'الطعام',
        merchant: 'مطعم عربي',
        paymentMethod: 'cash',
      ),
    ];

    final bytes = service.buildTripExpensesCsvBytes(
      trip: _createTrip(name: 'رحلة تجريبية', id: 'trip1'),
      expenses: expenses,
      receiptsCountByExpenseId: {},
    );

    expect(bytes.isNotEmpty, true);
    // Decode and check it contains Arabic text
    final decoded = utf8.decode(bytes);
    expect(decoded.contains('مطعم عربي'), true);
  });

  test('Filename generation is sanitized', () {
    final trip = _createTrip(name: 'My Trip! (2026)', id: 'trip1');
    final filename = CsvExportService.generateExportFilename(trip);

    expect(filename.contains('trip_expenses'), true);
    expect(filename.contains('my_trip'), true);
    expect(filename.contains('!'), false); // Special char removed
    expect(filename.endsWith('.csv'), true);
  });

  test('Empty expenses list produces only header', () {
    final csv = service.buildTripExpensesCsv(
      trip: _createTrip(name: 'Test Trip', id: 'trip1'),
      expenses: [],
      receiptsCountByExpenseId: {},
    );

    final lines = csv.split('\n');
    expect(lines.length, 1); // Only header
    expect(
      lines[0],
      'date,amount,currency,category,merchant,payment_type,payment_brand,payment_label,location_text,notes,has_receipts,receipts_count',
    );
  });

  test('Multi-currency expenses are included', () {
    final expenses = [
      _expense(
        id: '1',
        amount: 50.0,
        currency: 'USD',
        category: 'الطعام',
        merchant: 'Restaurant',
        paymentMethod: 'cash',
      ),
      _expense(
        id: '2',
        amount: 75.0,
        currency: 'EUR',
        category: 'المواصلات',
        merchant: 'Taxi',
        paymentMethod: 'card',
      ),
    ];

    final csv = service.buildTripExpensesCsv(
      trip: _createTrip(name: 'Test Trip', id: 'trip1'),
      expenses: expenses,
      receiptsCountByExpenseId: {},
    );

    expect(csv.contains('USD'), true);
    expect(csv.contains('EUR'), true);
  });
}
