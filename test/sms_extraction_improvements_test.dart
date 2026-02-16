import 'package:flutter_test/flutter_test.dart';
import 'package:travel_expenses/features/expenses/presentation/utils/sms_receipt_parser.dart';

void main() {
  group('SMS extraction improvements', () {
    test('Amazon SA sample parses merchant and amount', () {
      const sms = 'Payment used at Amazon SA for SAR 248.09 on 04/02/26';

      final r = parseSmsReceipt(sms);
      expect(r.amount, 248.09);
      expect(r.currency, 'SAR');
      expect(r.merchant, isNotNull);
      expect(r.merchant!.toLowerCase(), contains('amazon'));
    });

    test('Bill Payment sample with thousand separators', () {
      const sms = 'Bill Payment: SAR 15,000.00 was paid to biller ID 12345 on 01/02/26';

      final r = parseSmsReceipt(sms);
      expect(r.amount, 15000.00);
      expect(r.currency, 'SAR');
      expect(r.merchant, isNotNull);
    });

    test('Arabic New Tower sample parses merchant and amount', () {
      const sms = 'تم الدفع من New Tower بـ136.35 SAR في 04/02/26';

      final r = parseSmsReceipt(sms);
      expect(r.amount, 136.35);
      expect(r.currency, 'SAR');
      expect(r.merchant, isNotNull);
      expect(r.merchant, contains('New Tower'));
    });

    test('Arabic APPLE.COM sample extracts domain merchant', () {
      const sms = 'تم الشراء لدى:APPLE.COM مبلغ: 44.99 SAR';

      final r = parseSmsReceipt(sms);
      expect(r.amount, 44.99);
      expect(r.currency, 'SAR');
      expect(r.merchant, isNotNull);
      expect(r.merchant, contains('APPLE.COM'));
    });

    test('TABBY sample extracts merchant and amount', () {
      const sms = 'Payment via TABBY Amount: SAR 111.51';

      final r = parseSmsReceipt(sms);
      expect(r.amount, 111.51);
      expect(r.currency, 'SAR');
      expect(r.merchant, isNotNull);
      expect(r.merchant!.toUpperCase(), contains('TABBY'));
    });

    test('random text is safe and does not throw', () {
      const sms = 'Hello this is just a notification with no amounts or merchants';
      final r = parseSmsReceipt(sms);
      expect(r.amount, isNull);
      expect(r.currency, isNull);
      expect(r.merchant, isNull);
      expect(r.isUseful, false);
    });
  });
}
