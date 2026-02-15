class ExpenseDraft {
  final String? amountText;
  final String? currencyCode;
  final String? categoryId;
  final DateTime? date;
  final String? merchant;
  final String? paymentMethodType;
  final String? paymentBrand;
  final String? paymentLabel;
  final String? locationText;
  final String? notes;
  final bool hasReceipts;

  const ExpenseDraft({
    this.amountText,
    this.currencyCode,
    this.categoryId,
    this.date,
    this.merchant,
    this.paymentMethodType,
    this.paymentBrand,
    this.paymentLabel,
    this.locationText,
    this.notes,
    this.hasReceipts = false,
  });

  ExpenseDraft copyWith({
    Object? amountText = _sentinel,
    Object? currencyCode = _sentinel,
    Object? categoryId = _sentinel,
    Object? date = _sentinel,
    Object? merchant = _sentinel,
    Object? paymentMethodType = _sentinel,
    Object? paymentBrand = _sentinel,
    Object? paymentLabel = _sentinel,
    Object? locationText = _sentinel,
    Object? notes = _sentinel,
    Object? hasReceipts = _sentinel,
  }) {
    return ExpenseDraft(
      amountText:
          amountText == _sentinel ? this.amountText : amountText as String?,
      currencyCode: currencyCode == _sentinel
          ? this.currencyCode
          : currencyCode as String?,
      categoryId: categoryId == _sentinel
          ? this.categoryId
          : categoryId as String?,
      date: date == _sentinel ? this.date : date as DateTime?,
      merchant: merchant == _sentinel ? this.merchant : merchant as String?,
      paymentMethodType: paymentMethodType == _sentinel
          ? this.paymentMethodType
          : paymentMethodType as String?,
      paymentBrand: paymentBrand == _sentinel
          ? this.paymentBrand
          : paymentBrand as String?,
      paymentLabel: paymentLabel == _sentinel
          ? this.paymentLabel
          : paymentLabel as String?,
      locationText: locationText == _sentinel
          ? this.locationText
          : locationText as String?,
      notes: notes == _sentinel ? this.notes : notes as String?,
      hasReceipts: hasReceipts == _sentinel
          ? this.hasReceipts
          : hasReceipts as bool,
    );
  }

  bool get isEmpty {
    final hasAmount = (amountText?.trim().isNotEmpty ?? false);
    final hasCurrency = (currencyCode?.trim().isNotEmpty ?? false);
    final hasCategory = (categoryId?.trim().isNotEmpty ?? false);
    final hasDate = date != null;
    final hasMerchant = (merchant?.trim().isNotEmpty ?? false);
    final hasMethod = (paymentMethodType?.trim().isNotEmpty ?? false);
    final hasBrand = (paymentBrand?.trim().isNotEmpty ?? false);
    final hasLabel = (paymentLabel?.trim().isNotEmpty ?? false);
    final hasLocation = (locationText?.trim().isNotEmpty ?? false);
    final hasNotes = (notes?.trim().isNotEmpty ?? false);

    return !(hasAmount ||
        hasCurrency ||
        hasCategory ||
        hasDate ||
        hasMerchant ||
        hasMethod ||
        hasBrand ||
        hasLabel ||
        hasLocation ||
        hasNotes ||
        hasReceipts);
  }
}

const _sentinel = Object();
