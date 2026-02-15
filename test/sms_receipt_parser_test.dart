import 'package:flutter_test/flutter_test.dart';
import 'package:travel_expenses/features/expenses/presentation/utils/sms_receipt_parser.dart';

void main() {
  group('SMS Receipt Parser', () {
    test('parses Arabic POS receipt with Mastercard', () {
      const sms = '''
قامت بطاقة الأعمال فرسان
مشتريات مباشرة من شركة كريم Mastercard x-1234
مبلغ: 44.99 SAR في 22/12/24 الساعة 19:54
اجمالي:45.89 SAR
''';

      final result = parseSmsReceipt(sms);

      // Should extract amount (first valid amount found)
      expect(result.amount, 44.99);
      expect(result.currency, 'SAR');
      expect(result.merchant, 'شركة كريم');
      
      // Should parse date and time
      expect(result.dateTime, isNotNull);
      expect(result.dateTime!.day, 22);
      expect(result.dateTime!.month, 12);
      expect(result.dateTime!.year, 2024);
      expect(result.dateTime!.hour, 19);
      expect(result.dateTime!.minute, 54);

      // Should detect Mastercard
      expect(result.paymentType, 'card');
      expect(result.paymentBrand, 'mastercard');
      expect(result.paymentLabel, 'فرسان');

      // High confidence due to complete data
      expect(result.confidence, greaterThan(0.7));
      expect(result.isUseful, true);
    });

    test('parses Arabic internet purchase with Apple Pay', () {
      const sms = '''
سلام عليكم
تمت معاملة شراء إنترنت لدى: AMAZON.COM بـ136.35 SAR 
عبر Apple Pay (بطاقة الأعمال فرسان x-1234) 
في 21/12/24 الساعة 18:42
''';

      final result = parseSmsReceipt(sms);

      expect(result.amount, 136.35);
      expect(result.currency, 'SAR');
      expect(result.merchant, 'AMAZON.COM');
      
      expect(result.dateTime, isNotNull);
      expect(result.dateTime!.day, 21);
      expect(result.dateTime!.month, 12);
      expect(result.dateTime!.year, 2024);
      expect(result.dateTime!.hour, 18);
      expect(result.dateTime!.minute, 42);

      // Should detect Apple Pay (wallet type)
      expect(result.paymentType, 'wallet');
      expect(result.paymentBrand, 'apple_pay');
      expect(result.paymentLabel, 'فرسان');

      expect(result.confidence, greaterThan(0.7));
    });

    test('parses English receipt format', () {
      const sms = '''
Al Rajhi Bank
Purchase Transaction
At: STARBUCKS COFFEE
Amount: SAR 111.51
Balance: SAR 2,345.67
On 20/12/24 at 14:30
Card: x-5678
''';

      final result = parseSmsReceipt(sms);

      expect(result.amount, 111.51);
      expect(result.currency, 'SAR');
      expect(result.merchant, 'STARBUCKS COFFEE');
      
      expect(result.dateTime, isNotNull);
      expect(result.dateTime!.day, 20);
      expect(result.dateTime!.month, 12);
      expect(result.dateTime!.year, 2024);
      expect(result.dateTime!.hour, 14);
      expect(result.dateTime!.minute, 30);

      expect(result.paymentLabel, 'الراجحي');
      expect(result.confidence, greaterThan(0.7));
    });

    test('handles Arabic digits conversion', () {
      const sms = '''
مشتريات من المتجر
مبلغ: ٤٤.٩٩ SAR
في ٢٢/١٢/٢٤
''';

      final result = parseSmsReceipt(sms);

      // Should convert Arabic digits to English
      expect(result.amount, 44.99);
      expect(result.currency, 'SAR');
      
      expect(result.dateTime, isNotNull);
      expect(result.dateTime!.day, 22);
      expect(result.dateTime!.month, 12);
      expect(result.dateTime!.year, 2024);
    });

    test('returns low confidence for incomplete data', () {
      const sms = '''
شكراً لتعاملكم معنا
المتجر الكبير
نتمنى لكم يوماً سعيداً
''';

      final result = parseSmsReceipt(sms);

      // Should not extract anything meaningful
      expect(result.amount, isNull);
      expect(result.currency, isNull);
      expect(result.confidence, lessThan(0.3));
      expect(result.isUseful, false);
    });

    test('handles empty input', () {
      final result = parseSmsReceipt('');

      expect(result.amount, isNull);
      expect(result.currency, isNull);
      expect(result.merchant, isNull);
      expect(result.dateTime, isNull);
      expect(result.confidence, 0.0);
      expect(result.isUseful, false);
    });

    test('extracts amount with comma decimal separator', () {
      const sms = '''
مبلغ: 44,99 SAR
من المطعم
في 22/12/24
''';

      final result = parseSmsReceipt(sms);

      // Should handle comma as decimal separator
      expect(result.amount, 44.99);
    });

    test('handles different date formats', () {
      const sms1 = 'Amount: 50 SAR on 1/3/24';
      const sms2 = 'Amount: 50 SAR on 01/03/2024';
      
      final result1 = parseSmsReceipt(sms1);
      final result2 = parseSmsReceipt(sms2);

      expect(result1.dateTime, isNotNull);
      expect(result1.dateTime!.day, 1);
      expect(result1.dateTime!.month, 3);
      expect(result1.dateTime!.year, 2024);

      expect(result2.dateTime, isNotNull);
      expect(result2.dateTime!.day, 1);
      expect(result2.dateTime!.month, 3);
      expect(result2.dateTime!.year, 2024);
    });

    test('detects various payment brands', () {
      expect(parseSmsReceipt('visa card x-1234').paymentBrand, 'visa');
      expect(parseSmsReceipt('mastercard x-1234').paymentBrand, 'mastercard');
      expect(parseSmsReceipt('بطاقة مدى').paymentBrand, 'mada');
      expect(parseSmsReceipt('apple pay').paymentBrand, 'apple_pay');
      expect(parseSmsReceipt('دفع نقد').paymentType, 'cash');
    });

    test('extracts merchant from various formats', () {
      final sms1 = parseSmsReceipt('مشتريات من متجر الأثاث الحديث في 22/12/24');
      expect(sms1.merchant, 'متجر الأثاث الحديث');

      final sms2 = parseSmsReceipt('لدى: CARREFOUR مبلغ: 100 SAR');
      expect(sms2.merchant, 'CARREFOUR');

      final sms3 = parseSmsReceipt('At: IKEA Amount: 500 SAR');
      expect(sms3.merchant, 'IKEA');
    });
  });
}
