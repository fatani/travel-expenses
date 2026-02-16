import 'package:flutter_test/flutter_test.dart';
import 'package:travel_expenses/features/expenses/presentation/utils/sms_receipt_parser.dart';

void main() {
  group('SMS Merchant & Amount Extraction Improvements', () {
    test('Extract merchant from "used at Amazon SA for SAR 248.09"', () {
      const sms = 'Payment used at Amazon SA for SAR 248.09 on 04/02/26';
      final result = parseSmsReceipt(sms);

      expect(result.merchant, 'Amazon SA');
      expect(result.amount, 248.09);
      expect(result.currency, 'SAR');
    });

    test('Parse amount with thousands separator: "SAR 15,000.00"', () {
      const sms = 'Payment of SAR 15,000.00 was processed successfully';
      final result = parseSmsReceipt(sms);

      expect(result.amount, 15000.0);
      expect(result.currency, 'SAR');
    });

    test('Parse amount with only comma as thousands: "15,000"', () {
      const sms = 'Bill Payment 15,000 SAR completed';
      final result = parseSmsReceipt(sms);

      expect(result.amount, 15000.0);
      expect(result.currency, 'SAR');
    });

    test('Extract Arabic merchant: "من New Tower بـ 136.35 SAR"', () {
      const sms = 'عملية شراء من New Tower بـ 136.35 SAR';
      final result = parseSmsReceipt(sms);

      expect(result.merchant, 'New Tower');
      expect(result.amount, 136.35);
      expect(result.currency, 'SAR');
    });

    test('Extract merchant from "لدى:APPLE.COM مبلغ: 44.99 SAR"', () {
      const sms = 'تم الدفع لدى:APPLE.COM مبلغ: 44.99 SAR في 15/02/26';
      final result = parseSmsReceipt(sms);

      expect(result.merchant, 'APPLE.COM');
      expect(result.amount, 44.99);
      expect(result.currency, 'SAR');
    });

    test('Extract merchant from "At TABBY Amount:SAR 111.51"', () {
      const sms = 'Payment At TABBY Amount:SAR 111.51 on 04/02/26';
      final result = parseSmsReceipt(sms);

      expect(result.merchant, 'TABBY');
      expect(result.amount, 111.51);
      expect(result.currency, 'SAR');
    });

    test('Handle random text safely without crash', () {
      const sms = 'This is just a random message with no payment info';
      final result = parseSmsReceipt(sms);

      expect(result.amount, null);
      expect(result.merchant, null);
      expect(result.currency, null);
    });

    test('Extract domain name as merchant: "AMAZON.SA"', () {
      const sms = 'Purchase at AMAZON.SA for 299.99 SAR';
      final result = parseSmsReceipt(sms);

      expect(result.merchant, 'AMAZON.SA');
      expect(result.amount, 299.99);
    });

    test('Handle Bill Payment as merchant', () {
      const sms = 'Bill Payment of 1,500.00 SAR completed successfully';
      final result = parseSmsReceipt(sms);

      expect(result.merchant, 'Bill Payment');
      expect(result.amount, 1500.0);
    });

    test('Parse amount with decimal comma: "136,35"', () {
      const sms = 'Payment of 136,35 SAR at Store';
      final result = parseSmsReceipt(sms);

      expect(result.amount, 136.35);
      expect(result.currency, 'SAR');
    });

    test('Parse complex amount: "1,234,567.89 SAR"', () {
      const sms = 'Large payment of 1,234,567.89 SAR processed';
      final result = parseSmsReceipt(sms);

      expect(result.amount, 1234567.89);
      expect(result.currency, 'SAR');
    });

    test('Extract merchant with Arabic colon: "لدى: مطعم البيك"', () {
      const sms = 'عملية شراء لدى: مطعم البيك بمبلغ 45.50 SAR';
      final result = parseSmsReceipt(sms);

      expect(result.merchant, 'مطعم البيك');
      expect(result.amount, 45.50);
    });

    test('Handle merchant with trailing semicolon', () {
      const sms = 'Payment from New Tower; Amount: 100.00 SAR';
      final result = parseSmsReceipt(sms);

      expect(result.merchant, 'New Tower');
      expect(result.amount, 100.0);
    });

    test('Recognize NOON as merchant', () {
      const sms = 'Purchase at NOON for 599.00 SAR';
      final result = parseSmsReceipt(sms);

      expect(result.merchant, 'NOON');
      expect(result.amount, 599.0);
    });

    test('Extract amount from "مبلغ: 15,250.75 SAR"', () {
      const sms = 'تم الدفع مبلغ: 15,250.75 SAR بنجاح';
      final result = parseSmsReceipt(sms);

      expect(result.amount, 15250.75);
      expect(result.currency, 'SAR');
    });
  });
}
