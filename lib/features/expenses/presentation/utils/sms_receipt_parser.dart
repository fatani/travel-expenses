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

String normalizeToken(String? s) {
  if (s == null) return '';
  final t = s.trim().toLowerCase();
  final collapsed = t.replaceAll(RegExp(r'\s+'), ' ');
  return collapsed.replaceAll(RegExp(r'[^a-z0-9_ ]'), '');
}

String? canonicalBrand(String? raw) {
  final n = normalizeToken(raw);
  if (n.isEmpty) return null;
  if (n.contains('mastercard') || n.contains('master card')) return 'mastercard';
  if (n.contains('visa')) return 'visa';
  if (n.contains('amex') || n.contains('american express')) return 'amex';
  if (n.contains('apple pay') || n.contains('applepay')) return 'apple_pay';
  if (n.contains('mada')) return 'mada';
  return n.replaceAll(' ', '_');
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
  text = text.replaceAll('٫', '.');
  text = text.replaceAll('٬', ',');

  // إزالة Zero Width characters
  text = text.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '');

  return text;
}

double? _parseAmountString(String value) {
  var cleaned = value.trim();
  
  // Handle both comma and dot
  if (cleaned.contains(',') && cleaned.contains('.')) {
    // Both present: comma is thousands separator, dot is decimal
    cleaned = cleaned.replaceAll(',', '');
  } else if (cleaned.contains(',') && !cleaned.contains('.')) {
    // Only comma: check if it's thousands or decimal
    final parts = cleaned.split(',');
    if (parts.length == 2 && parts[1].length == 3) {
      // Last part is 3 digits → thousands separator
      // Check if there are more commas (e.g., 1,000,000)
      cleaned = cleaned.replaceAll(',', '');
    } else {
      // Last part is not 3 digits → decimal separator
      cleaned = cleaned.replaceAll(',', '.');
    }
  }

  final parsed = double.tryParse(cleaned);
  if (parsed != null && parsed > 0) {
    return parsed;
  }
  return null;
}

double? _extractAmount(String text) {
  final amountCore = r'(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d+)?)';
  // أنماط مختلفة للمبلغ
  final patterns = [
    // "Amount:SAR 111.51" or "Amount: SAR 111.51"
  RegExp(r'Amount\s*:\s*(?:SAR|USD|EUR|GBP|AED|KWD|QAR|OMR|BHD|JOD|TRY|CNY|JPY)?\s*' + amountCore,
        caseSensitive: false),
    // "مبلغ: 44.99 SAR"
  RegExp(r'مبلغ\s*:\s*' + amountCore + r'\s*(?:SAR|USD|EUR|GBP|AED|KWD|QAR|OMR|BHD|JOD|TRY|CNY|JPY)?',
        caseSensitive: false),
    // "بـ136.35 SAR" or "ب 136.35 SAR"
  RegExp(r'بـ?\s*' + amountCore + r'\s*(?:SAR|USD|EUR|GBP|AED|KWD|QAR|OMR|BHD|JOD|TRY|CNY|JPY)',
        caseSensitive: false),
    // "SAR 111.51"
  RegExp(r'(?:SAR|USD|EUR|GBP|AED|KWD|QAR|OMR|BHD|JOD|TRY|CNY|JPY)\s*' + amountCore,
        caseSensitive: false),
    // "111.51 SAR"
  RegExp(amountCore + r'\s*(?:SAR|USD|EUR|GBP|AED|KWD|QAR|OMR|BHD|JOD|TRY|CNY|JPY)',
        caseSensitive: false),
    // "اجمالي:45.89 SAR" أو "إجمالي: 45.89 SAR"
  RegExp(r'ا[جإ]مالي\s*:\s*' + amountCore + r'\s*(?:SAR|USD|EUR|GBP|AED|KWD|QAR|OMR|BHD|JOD|TRY|CNY|JPY)?',
        caseSensitive: false),
  ];

  for (final pattern in patterns) {
    final match = pattern.firstMatch(text);
    if (match != null && match.group(1) != null) {
      final amountStr = match.group(1)!;
      final parsed = _parseAmountString(amountStr);
      if (parsed != null) return parsed;
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
    RegExp(r'من\s+([^\n]+?)(?:\s+(?:Mastercard|Visa|مدى|بـ?|في|بمبلغ|مبلغ|Amount|Balance|رصيد|On|for|;|\(|x-|\d{1,2}/\d{1,2}/\d|SAR|USD|EUR|GBP)|$)', caseSensitive: false),
    RegExp(r'لدى\s*:\s*([^\n]+?)(?:\s+(?:Mastercard|Visa|مدى|بـ?|في|بمبلغ|مبلغ|Amount|Balance|رصيد|On|for|;|\(|SAR|USD|EUR|GBP)|$)', caseSensitive: false),
    RegExp(r'لدى\s+([^\n]+?)(?:\s+(?:Mastercard|Visa|مدى|بـ?|في|بمبلغ|مبلغ|Amount|Balance|رصيد|On|for|;|\(|SAR|USD|EUR|GBP)|$)', caseSensitive: false),
  ];

  for (final pattern in arabicPatterns) {
    final match = pattern.firstMatch(text);
    if (match != null && match.group(1) != null) {
      final merchant = _cleanMerchantName(match.group(1)!);
      if (merchant.isNotEmpty) return merchant;
    }
  }

  // English patterns: "used at", "At:", "From:", "from"
  final englishPatterns = [
    RegExp(r'used\s+at\s+([^\n]+?)(?:\s+(?:for|on|amount|balance|;|\(|\d{1,2}/\d{1,2}/\d|SAR|USD|EUR|GBP)|$)', caseSensitive: false),
    RegExp(r'At\s*:\s*([^\n]+?)(?:\s+(?:Amount|Balance|On|for|;|\(|\d{1,2}/\d{1,2}/\d|SAR|USD|EUR|GBP)|\n|$)', caseSensitive: false),
    RegExp(r'From\s*:\s*([^\n]+?)(?:\s+(?:Amount|Balance|On|for|;|\(|\d{1,2}/\d{1,2}/\d|SAR|USD|EUR|GBP)|\n|$)', caseSensitive: false),
    RegExp(r'\bfrom\s+([^\n]+?)(?:\s*[;,]|\s+(?:Amount|Balance|On|for|\(|\d{1,2}/\d{1,2}/\d|SAR|USD|EUR|GBP)|\n|$)', caseSensitive: false),
    RegExp(r'\bAt\s+([^\n]+?)(?:\s+(?:Amount|Balance|On|for|;|\(|\d{1,2}/\d{1,2}/\d|SAR|USD|EUR|GBP)|\n|$)', caseSensitive: false),
    RegExp(r'\bat\s+([^\n]+?)(?:\s+(?:for|amount|balance|on|;|\(|\d{1,2}/\d{1,2}/\d|SAR|USD|EUR|GBP)|\n|$)', caseSensitive: false),
    RegExp(r'\bvia\s+([^\n]+?)(?:\s+(?:amount|balance|on|for|;|\(|\d{1,2}/\d{1,2}/\d|SAR|USD|EUR|GBP)|\n|$)', caseSensitive: false),
    RegExp(r'\bto\s+([^\n]+?)(?:\s+(?:on|amount|balance|for|;|\(|\d{1,2}/\d{1,2}/\d|SAR|USD|EUR|GBP)|\n|$)', caseSensitive: false),
  ];

  for (final pattern in englishPatterns) {
    final match = pattern.firstMatch(text);
    if (match != null && match.group(1) != null) {
      final merchant = _cleanMerchantName(match.group(1)!);
      if (merchant.isNotEmpty) return merchant;
    }
  }

  // Fallback: look for domain names or known merchants
  final domainPattern = RegExp(r'\b([A-Z][A-Z0-9]*(?:\.[A-Z]{2,})+)\b', caseSensitive: false);
  final domainMatch = domainPattern.firstMatch(text);
  if (domainMatch != null && domainMatch.group(1) != null) {
    final domain = domainMatch.group(1)!;
    // Check if it's a valid domain (contains at least one dot)
    if (domain.contains('.')) {
      return domain.toUpperCase();
    }
  }

  // Check for "Bill Payment"
  if (text.toLowerCase().contains('bill payment')) {
    return 'Bill Payment';
  }

  // Look for standalone merchant names (TABBY, AMAZON, etc.)
  final merchantKeywords = ['TABBY', 'AMAZON', 'APPLE', 'GOOGLE', 'UBER', 'CAREEM', 'NOON', 'JARIR', 'EXTRA'];
  for (final keyword in merchantKeywords) {
    if (text.toUpperCase().contains(keyword)) {
      return keyword;
    }
  }

  return null;
}

String _cleanMerchantName(String raw) {
  var cleaned = raw.trim();
  
  // Remove trailing punctuation and symbols
  cleaned = cleaned.replaceAll(RegExp(r'[;،،,]+$'), '');
  
  // Remove leading/trailing special characters
  cleaned = cleaned.replaceAll(RegExp(r'^[\s:،,;]+'), '');
  cleaned = cleaned.replaceAll(RegExp(r'[\s:،,;]+$'), '');
  
  // Collapse multiple spaces
  cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
  
  return cleaned.trim();
}

DateTime? _extractDateTime(String text) {
  return parseBestEffortDate(text, DateTime.fromMillisecondsSinceEpoch(0));
}

DateTime? parseBestEffortDate(String text, DateTime fallback) {
  final _ = fallback;
  final iso = RegExp(
    r'(\d{4})-(\d{2})-(\d{2})(?:[ T](\d{1,2}):(\d{2})(?::(\d{2}))?)?',
  );
  final isoMatch = iso.firstMatch(text);
  if (isoMatch != null) {
    final year = int.tryParse(isoMatch.group(1) ?? '');
    final month = int.tryParse(isoMatch.group(2) ?? '');
    final day = int.tryParse(isoMatch.group(3) ?? '');
    if (year != null && month != null && day != null) {
      final hour = int.tryParse(isoMatch.group(4) ?? '') ?? 0;
      final minute = int.tryParse(isoMatch.group(5) ?? '') ?? 0;
      final second = int.tryParse(isoMatch.group(6) ?? '') ?? 0;
      return DateTime(year, month, day, hour, minute, second);
    }
  }

  final slash = RegExp(r'(\d{1,2})/(\d{1,2})/(\d{2,4})');
  final slashMatch = slash.firstMatch(text);
  if (slashMatch != null) {
    final day = int.tryParse(slashMatch.group(1) ?? '');
    final month = int.tryParse(slashMatch.group(2) ?? '');
    var year = int.tryParse(slashMatch.group(3) ?? '');
    if (day != null && month != null && year != null) {
      if (year < 100) year += 2000;
      final time = _extractTime(text);
      return DateTime(year, month, day, time.hour, time.minute, time.second);
    }
  }

  final dash = RegExp(r'(\d{1,2})-(\d{1,2})-(\d{2,4})');
  final dashMatch = dash.firstMatch(text);
  if (dashMatch != null) {
    final day = int.tryParse(dashMatch.group(1) ?? '');
    final month = int.tryParse(dashMatch.group(2) ?? '');
    var year = int.tryParse(dashMatch.group(3) ?? '');
    if (day != null && month != null && year != null) {
      if (year < 100) year += 2000;
      final time = _extractTime(text);
      return DateTime(year, month, day, time.hour, time.minute, time.second);
    }
  }

  return null;
}

({int hour, int minute, int second}) _extractTime(String text) {
  final timePattern = RegExp(r'(\d{1,2}):(\d{2})(?::(\d{2}))?');
  final match = timePattern.firstMatch(text);
  if (match == null) {
    return (hour: 0, minute: 0, second: 0);
  }

  final hour = int.tryParse(match.group(1) ?? '') ?? 0;
  final minute = int.tryParse(match.group(2) ?? '') ?? 0;
  final second = int.tryParse(match.group(3) ?? '') ?? 0;
  return (hour: hour, minute: minute, second: second);
}

({String? type, String? brand, String? label}) _extractPaymentInfo(String text) {
  String? type;
  String? brand;
  String? label;

  final lowerText = text.toLowerCase();
  final normalizedToken = normalizeToken(text);

  // Check for payment methods
  if (normalizedToken.contains('apple pay') || normalizedToken.contains('applepay')) {
    type = 'wallet';
    brand = 'apple_pay';
  }

  if (normalizedToken.contains('mastercard') || normalizedToken.contains('master card')) {
    type ??= 'card';
    brand = 'mastercard';
  }

  if (normalizedToken.contains('visa') && brand != 'mastercard') {
    type ??= 'card';
    brand = 'visa';
  }

  if (normalizedToken.contains('amex') || normalizedToken.contains('american express')) {
    type ??= 'card';
    brand = 'amex';
  }

  if (lowerText.contains('مدى') || normalizedToken.contains('mada')) {
    type ??= 'card';
    brand = 'mada';
  }

  if (lowerText.contains('نقد')) {
    type = 'cash';
  }

  brand = canonicalBrand(brand) ?? brand;

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
