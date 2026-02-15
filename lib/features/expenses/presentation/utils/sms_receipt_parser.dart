class SmsParseResult {
  final double? amount;
  final String? currency;
  final String? merchant;
  final DateTime? dateTime;
  final String? paymentType;
  final String? paymentBrand;
  final String? paymentLabel;
  final String? raw;
  final double confidence;

  const SmsParseResult({
    this.amount,
    this.currency,
    this.merchant,
    this.dateTime,
    this.paymentType,
    this.paymentBrand,
    this.paymentLabel,
    this.raw,
    this.confidence = 0.0,
  });

  bool get isUseful => amount != null || merchant != null || dateTime != null;
}

SmsParseResult parseSmsReceipt(String input) {
  if (input.trim().isEmpty) {
    return const SmsParseResult();
  }

  final normalized = _normalize(input);

  final amount = _extractAmount(normalized);
  final currency = _extractCurrency(normalized);
  final merchant = _extractMerchant(normalized);
  final dateTime = _extractDateTime(normalized);
  final paymentInfo = _extractPaymentInfo(normalized);

  var confidence = 0.0;
  if (amount != null && currency != null) confidence += 0.6;
  if (merchant != null) confidence += 0.2;
  if (dateTime != null) confidence += 0.1;
  if (paymentInfo.brand != null) confidence += 0.1;
  if (confidence > 1.0) confidence = 1.0;

  return SmsParseResult(
    amount: amount,
    currency: currency,
    merchant: merchant,
    dateTime: dateTime,
    paymentType: paymentInfo.type,
    paymentBrand: paymentInfo.brand,
    paymentLabel: paymentInfo.label,
    raw: input,
    confidence: confidence,
  );
}

String _normalize(String input) {
  var text = input.trim();

  // تحويل الأرقام العربية إلى إنجليزية
  const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
  const englishDigits = '0123456789';
  for (var i = 0; i < arabicDigits.length; i++) {
    text = text.replaceAll(arabicDigits[i], englishDigits[i]);
  }

  // توحيد الفواصل
  text = text.replaceAll('،', ',');

  // إزالة Zero Width characters
  text = text.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');

  return text;
}

double? _extractAmount(String text) {
  // أنماط مختلفة للمبلغ
  final patterns = [
    // "Amount:SAR 111.51" or "Amount: SAR 111.51"
    RegExp(r'Amount\s*:\s*(?:SAR|USD|EUR|GBP|AED|KWD|QAR|OMR|BHD|JOD|TRY|CNY|JPY)?\s*(\d+(?:[.,]\d+)?)',
        caseSensitive: false),
    // "مبلغ: 44.99 SAR"
    RegExp(r'مبلغ\s*:\s*(\d+(?:[.,]\d+)?)\s*(?:SAR|USD|EUR|GBP|AED|KWD|QAR|OMR|BHD|JOD|TRY|CNY|JPY)?',
        caseSensitive: false),
    // "بـ136.35 SAR" or "ب 136.35 SAR"
    RegExp(r'بـ?\s*(\d+(?:[.,]\d+)?)\s*(?:SAR|USD|EUR|GBP|AED|KWD|QAR|OMR|BHD|JOD|TRY|CNY|JPY)',
        caseSensitive: false),
    // "SAR 111.51"
    RegExp(r'(?:SAR|USD|EUR|GBP|AED|KWD|QAR|OMR|BHD|JOD|TRY|CNY|JPY)\s*(\d+(?:[.,]\d+)?)',
        caseSensitive: false),
    // "111.51 SAR"
    RegExp(r'(\d+(?:[.,]\d+)?)\s*(?:SAR|USD|EUR|GBP|AED|KWD|QAR|OMR|BHD|JOD|TRY|CNY|JPY)',
        caseSensitive: false),
    // "اجمالي:45.89 SAR" أو "إجمالي: 45.89 SAR"
    RegExp(r'ا[جإ]مالي\s*:\s*(\d+(?:[.,]\d+)?)\s*(?:SAR|USD|EUR|GBP|AED|KWD|QAR|OMR|BHD|JOD|TRY|CNY|JPY)?',
        caseSensitive: false),
  ];

  for (final pattern in patterns) {
    final match = pattern.firstMatch(text);
    if (match != null && match.group(1) != null) {
      final amountStr = match.group(1)!.replaceAll(',', '.');
      final parsed = double.tryParse(amountStr);
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }
  }

  return null;
}

String? _extractCurrency(String text) {
  final currencyPattern = RegExp(
    r'\b(SAR|USD|EUR|GBP|AED|KWD|QAR|OMR|BHD|JOD|TRY|CNY|JPY)\b',
    caseSensitive: false,
  );

  final match = currencyPattern.firstMatch(text);
  if (match != null) {
    return match.group(1)!.toUpperCase();
  }

  return null;
}

String? _extractMerchant(String text) {
  // Arabic patterns: "من", "لدى:", "لدى"
  final arabicPatterns = [
    RegExp(r'من\s+([^\n]+?)(?:\s+(?:Mastercard|Visa|مدى|بـ|في|مبلغ|Amount|Balance|رصيد|On|\(|x-|\d{1,2}/\d{1,2}/\d|$))', caseSensitive: false),
    RegExp(r'لدى\s*:\s*([^\n]+?)(?:\s+(?:Mastercard|Visa|مدى|بـ|في|مبلغ|Amount|Balance|رصيد|On|\(|$))', caseSensitive: false),
    RegExp(r'لدى\s+([^\n]+?)(?:\s+(?:Mastercard|Visa|مدى|بـ|في|مبلغ|Amount|Balance|رصيد|On|\(|$))', caseSensitive: false),
  ];

  for (final pattern in arabicPatterns) {
    final match = pattern.firstMatch(text);
    if (match != null && match.group(1) != null) {
      return match.group(1)!.trim();
    }
  }

  // English patterns: "At:", "From:"
  final englishPatterns = [
    RegExp(r'At\s*:\s*([^\n]+?)(?:\s+(?:Amount|Balance|On|\(|\d{1,2}/\d{1,2}/\d)|\n|$)', caseSensitive: false),
    RegExp(r'From\s*:\s*([^\n]+?)(?:\s+(?:Amount|Balance|On|\(|\d{1,2}/\d{1,2}/\d)|\n|$)', caseSensitive: false),
  ];

  for (final pattern in englishPatterns) {
    final match = pattern.firstMatch(text);
    if (match != null && match.group(1) != null) {
      return match.group(1)!.trim();
    }
  }

  return null;
}

DateTime? _extractDateTime(String text) {
  // Date patterns: dd/MM/yy, d/M/yy, dd-MM-yyyy
  final datePattern = RegExp(
    r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})',
  );

  // Time patterns: HH:mm
  final timePattern = RegExp(
    r'(\d{1,2}):(\d{2})',
  );

  final dateMatch = datePattern.firstMatch(text);
  if (dateMatch == null) {
    return null;
  }

  final day = int.tryParse(dateMatch.group(1)!);
  final month = int.tryParse(dateMatch.group(2)!);
  var yearStr = dateMatch.group(3)!;

  if (day == null || month == null || day < 1 || day > 31 || month < 1 || month > 12) {
    return null;
  }

  // Convert yy to yyyy
  var year = int.tryParse(yearStr);
  if (year == null) {
    return null;
  }
  if (year < 100) {
    year += 2000;
  }

  var hour = 0;
  var minute = 0;

  final timeMatch = timePattern.firstMatch(text);
  if (timeMatch != null) {
    hour = int.tryParse(timeMatch.group(1)!) ?? 0;
    minute = int.tryParse(timeMatch.group(2)!) ?? 0;
  }

  try {
    return DateTime(year, month, day, hour, minute);
  } catch (e) {
    return null;
  }
}

({String? type, String? brand, String? label}) _extractPaymentInfo(String text) {
  String? type;
  String? brand;
  String? label;

  final lowerText = text.toLowerCase();

  // Check for payment methods
  if (lowerText.contains('apple pay')) {
    type = 'wallet';
    brand = 'apple_pay';
  }

  if (lowerText.contains('mastercard')) {
    type ??= 'card';
    brand = 'mastercard';
  }

  if (lowerText.contains('visa') && brand != 'mastercard') {
    type = 'card';
    brand = 'visa';
  }

  if (lowerText.contains('amex') || lowerText.contains('american express')) {
    type = 'card';
    brand = 'amex';
  }

  if (lowerText.contains('مدى') || lowerText.contains('mada')) {
    type = 'card';
    brand = 'mada';
  }

  if (lowerText.contains('نقد')) {
    type = 'cash';
  }

  // Extract label (bank name or card nickname)
  final labelPatterns = [
    'فرسان',
    'الراجحي',
    'rajhi',
    'ساب',
    'الأهلي',
    'الإنماء',
    'البلاد',
  ];

  for (final labelPattern in labelPatterns) {
    if (lowerText.contains(labelPattern)) {
      // Return Arabic name regardless of input language
      if (labelPattern == 'rajhi') {
        label = 'الراجحي';
      } else {
        label = labelPattern;
      }
      break;
    }
  }

  return (type: type, brand: brand, label: label);
}
