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

  test('CSV includes payment brand and label fields', () {
    final expenses = [
      _expense(
        id: '1',
        amount: 100.0,
        currency: 'USD',
        category: 'الإقامة',
        merchant: 'فندق ماريوت',
        paymentMethod: 'card',
        paymentMethodBrand: 'mastercard',
        paymentMethodLabel: 'فرسان ساب',
      ),
    ];

    final csv = service.buildTripExpensesCsv(
      trip: _createTrip(name: 'Test Trip', id: 'trip1'),
      expenses: expenses,
      receiptsCountByExpenseId: {},
    );

    expect(csv.contains('mastercard'), true);
    expect(csv.contains('فرسان ساب'), true);
  });

  test('CSV includes location_text field', () {
    final expenses = [
      _expense(
        id: '1',
        amount: 100.0,
        currency: 'USD',
        category: 'الإقامة',
        merchant: 'فندق ماريوت',
        paymentMethod: 'card',
        locationText: 'مطار الدوحة',
      ),
    ];

    final csv = service.buildTripExpensesCsv(
      trip: _createTrip(name: 'Test Trip', id: 'trip1'),
      expenses: expenses,
      receiptsCountByExpenseId: {},
    );

    expect(csv.contains('مطار الدوحة'), true);
  });

  test('CSV row with payment brand and location renders all fields', () {
    final expenses = [
      _expense(
        id: '2',
        amount: 30.0,
        currency: 'GBP',
        category: 'الإقامة',
        merchant: 'فندق ماريوت',
        paymentMethod: 'card',
        paymentMethodBrand: 'mastercard',
        paymentMethodLabel: 'فرسان ساب',
        locationText: 'مطار الدوحة',
        note: null,
      ),
    ];

    final csv = service.buildTripExpensesCsv(
      trip: _createTrip(name: 'Test Trip', id: 'trip1'),
      expenses: expenses,
      receiptsCountByExpenseId: {'2': 1},
    );

    final lines = csv.split('\n');
    expect(lines.length, 2); // header + 1 expense
    final dataRow = lines[1];

    // Verify specific fields in the row
    expect(dataRow.contains('فندق ماريوت'), true);
    expect(dataRow.contains('mastercard'), true);
    expect(dataRow.contains('فرسان ساب'), true);
    expect(dataRow.contains('مطار الدوحة'), true);
    expect(dataRow.endsWith(',true,1'), true); // has_receipts=true, receipts_count=1
  });

  test(
      'CSV with complex spec data (SAR/GBP/EUR multi-currency with Arabic)',
      () {
    final expenses = [
      _expense(
        id: '1',
        amount: 20.0,
        currency: 'SAR',
        category: 'الطعام',
        merchant: 'غير معروف',
        paymentMethod: 'wallet',
        note: null,
      ),
      _expense(
        id: '2',
        amount: 30.0,
        currency: 'GBP',
        category: 'الإقامة',
        merchant: 'فندق ماريوت',
        paymentMethod: 'card',
        paymentMethodBrand: 'mastercard',
        paymentMethodLabel: 'فرسان ساب',
        locationText: 'مطار الدوحة',
        note: null,
      ),
      _expense(
        id: '3',
        amount: 63.0,
        currency: 'EUR',
        category: 'الإقامة',
        merchant: 'فندق رامادا',
        paymentMethod: 'card',
        paymentMethodBrand: 'mastercard',
        paymentMethodLabel: null,
        locationText: null,
        note: null,
      ),
      _expense(
        id: '4',
        amount: 300.0,
        currency: 'EUR',
        category: 'الطعام',
        merchant: 'مطعم صيني',
        paymentMethod: 'card',
        note: 'وجبة',
      ),
    ];

    final csv = service.buildTripExpensesCsv(
      trip: _createTrip(name: 'Test Trip', id: 'trip1'),
      expenses: expenses,
      receiptsCountByExpenseId: {
        '2': 1,
        '4': 2,
      },
    );

    final lines = csv.split('\n');

    // Should have header + 4 expenses
    expect(lines.length, 5);

    // Verify header is present
    expect(
      lines[0].startsWith(
          'date,amount,currency,category,merchant,payment_type'),
      true,
    );

    // Verify all currencies appear in CSV
    expect(csv.contains('SAR'), true);
    expect(csv.contains('GBP'), true);
    expect(csv.contains('EUR'), true);

    // Verify Arabic text is present
    expect(csv.contains('غير معروف'), true);
    expect(csv.contains('فندق ماريوت'), true);
    expect(csv.contains('فندق رامادا'), true);
    expect(csv.contains('مطعم صيني'), true);
    expect(csv.contains('وجبة'), true);

    // Verify payment brand/label/location for mariott row
    expect(csv.contains('mastercard'), true);
    expect(csv.contains('فرسان ساب'), true);
    expect(csv.contains('مطار الدوحة'), true);

    // Verify receipt counts
    expect(csv.contains(',true,1'), true); // expense 2 has receipt
    expect(csv.contains(',true,2'), true); // expense 4 has 2 receipts
  });

  test('CSV handles Arabic notes with proper UTF-8 encoding', () {
    final expenses = [
      _expense(
        id: '1',
        amount: 300.0,
        currency: 'EUR',
        category: 'الطعام',
        merchant: 'مطعم صيني',
        paymentMethod: 'card',
        note: 'وجبة عشاء مميزة',
      ),
    ];

    final bytes = service.buildTripExpensesCsvBytes(
      trip: _createTrip(name: 'رحلة', id: 'trip1'),
      expenses: expenses,
      receiptsCountByExpenseId: {},
    );

    final decoded = utf8.decode(bytes);
    expect(decoded.contains('وجبة عشاء مميزة'), true);
    expect(decoded.contains('مطعم صيني'), true);
  });

  test('CSV row count matches expenses count plus header', () {
    final expenses = [
      _expense(
        id: '1',
        amount: 20.0,
        currency: 'SAR',
        category: 'الطعام',
        merchant: 'غير معروف',
        paymentMethod: 'wallet',
      ),
      _expense(
        id: '2',
        amount: 30.0,
        currency: 'GBP',
        category: 'الإقامة',
        merchant: 'فندق ماريوت',
        paymentMethod: 'card',
      ),
      _expense(
        id: '3',
        amount: 63.0,
        currency: 'EUR',
        category: 'الإقامة',
        merchant: 'فندق رامادا',
        paymentMethod: 'card',
      ),
      _expense(
        id: '4',
        amount: 300.0,
        currency: 'EUR',
        category: 'الطعام',
        merchant: 'مطعم صيني',
        paymentMethod: 'card',
      ),
    ];

    final csv = service.buildTripExpensesCsv(
      trip: _createTrip(name: 'Test Trip', id: 'trip1'),
      expenses: expenses,
      receiptsCountByExpenseId: {},
    );

    final lines = csv.split('\n').where((line) => line.isNotEmpty).toList();
    expect(lines.length, 5); // header + 4 data rows
  });
}


