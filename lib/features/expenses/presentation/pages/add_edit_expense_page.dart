import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/models/expense.dart';
import '../../../../core/models/receipt.dart';
import '../../../receipts/presentation/providers/receipts_providers.dart';
import '../../../receipts/presentation/widgets/receipt_gallery.dart';
import '../models/expense_draft.dart';
import '../providers/expense_draft_provider.dart';
import '../providers/expenses_providers.dart';
import '../providers/ocr_suggestion_provider.dart';
import '../utils/sms_receipt_parser.dart';

class AddEditExpensePage extends ConsumerStatefulWidget {
  final String tripId;
  final String tripCurrency;
  final Expense? expense;

  const AddEditExpensePage({
    super.key,
    required this.tripId,
    required this.tripCurrency,
    this.expense,
  });

  @override
  ConsumerState<AddEditExpensePage> createState() => _AddEditExpensePageState();
}

class _AddEditExpensePageState extends ConsumerState<AddEditExpensePage> {
  static const String _paymentPrefKey = 'last_payment_method_type';

  final _formKey = GlobalKey<FormState>();
  final _amountFieldKey = GlobalKey();
  final _currencyFieldKey = GlobalKey();
  final _categoryFieldKey = GlobalKey();
  final _dateFieldKey = GlobalKey();
  final _merchantFieldKey = GlobalKey();
  final _locationFieldKey = GlobalKey();
  final _noteFieldKey = GlobalKey();
  final _receiptsSectionKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TextEditingController _merchantController;
  late TextEditingController _locationController;
  late TextEditingController _paymentLabelController;
  late TextEditingController _smsInputController;
  late String _selectedCategory;
  late String _selectedCurrency;
  late String _selectedPaymentMethod;
  String? _selectedPaymentBrand;
  late DateTime _selectedDate;
  String? _newExpenseId; // Track newly created expense
  bool _wantsReceipt = false;
  String? _selectedReceiptId;
  bool _showAppliedSuggestionMessage = false;
  bool _draftAppliedOnce = false;
  bool _draftUpdatesEnabled = false;
  String? _smsParseMessage;

  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _currencyFocusNode = FocusNode();
  final FocusNode _categoryFocusNode = FocusNode();
  final FocusNode _dateFocusNode = FocusNode();
  final FocusNode _merchantFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();
  final FocusNode _noteFocusNode = FocusNode();

  final List<String> _categories = [
    'الطعام',
    'المواصلات',
    'الإقامة',
    'التسوق',
    'أخرى',
  ];

  final Map<String, String> _paymentMethods = {
    'cash': 'نقد',
    'card': 'بطاقة',
    'wallet': 'محفظة رقمية',
    'other': 'أخرى',
  };

  final Map<String, String> _cardBrands = {
    'visa': 'Visa',
    'mastercard': 'Mastercard',
    'mada': 'Mada',
    'amex': 'Amex',
    'other': 'Other',
  };

  final Map<String, String> _walletBrands = {
    'apple_pay': 'Apple Pay',
    'google_pay': 'Google Pay',
    'stc_pay': 'STC Pay',
    'other': 'Other',
  };

  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      _amountController = TextEditingController(
        text: widget.expense!.amount.toString(),
      );
      _noteController = TextEditingController(text: widget.expense!.note ?? '');
      _merchantController = TextEditingController(text: widget.expense!.merchant);
      _locationController = TextEditingController(text: widget.expense!.locationText ?? '');
      _paymentLabelController = TextEditingController(
        text: widget.expense!.paymentMethodLabel ?? '',
      );
      _selectedCategory = widget.expense!.category;
      _selectedCurrency = widget.expense!.currency;
      _selectedPaymentMethod = widget.expense!.paymentMethod;
      _selectedPaymentBrand = widget.expense!.paymentMethodBrand;
      _selectedDate = widget.expense!.date;
    } else {
      _amountController = TextEditingController();
      _noteController = TextEditingController();
      _merchantController = TextEditingController();
      _locationController = TextEditingController();
      _paymentLabelController = TextEditingController();
      _smsInputController = TextEditingController();
      _selectedCategory = _categories.first;
      _selectedCurrency = widget.tripCurrency;
      _selectedPaymentMethod = _paymentMethods.keys.first;
      _selectedPaymentBrand = null;
      _selectedDate = DateTime.now();
      _wantsReceipt = false;
      final draft = ref.read(expenseDraftProvider(widget.tripId));
      if (!_draftAppliedOnce && !draft.isEmpty) {
        _applyDraft(draft);
      } else {
        _loadPaymentMethodPreference();
      }
      _draftAppliedOnce = true;
    }

    if (!_shouldShowPaymentDetails(_selectedPaymentMethod)) {
      _resetPaymentDetails();
    }

    _bindDraftListeners();
    _draftUpdatesEnabled = true;
  }

  @override
  void dispose() {
    _removeDraftListeners();
    _amountController.dispose();
    _noteController.dispose();
    _merchantController.dispose();
    _locationController.dispose();
    _paymentLabelController.dispose();
    _smsInputController.dispose();
    _amountFocusNode.dispose();
    _currencyFocusNode.dispose();
    _categoryFocusNode.dispose();
    _dateFocusNode.dispose();
    _merchantFocusNode.dispose();
    _locationFocusNode.dispose();
    _noteFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethodPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_paymentPrefKey) ?? 'cash';
    if (!mounted) {
      return;
    }
    _setPaymentMethodType(stored, persist: false);
  }

  Future<void> _persistPaymentMethod(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paymentPrefKey, value);
  }

  bool _shouldShowPaymentDetails(String type) {
    return type == 'card' || type == 'wallet';
  }

  void _resetPaymentDetails() {
    _selectedPaymentBrand = null;
    _paymentLabelController.text = '';
  }

  void _setPaymentMethodType(String value, {bool persist = true}) {
    setState(() {
      _selectedPaymentMethod = value;
      if (!_shouldShowPaymentDetails(value)) {
        _resetPaymentDetails();
      } else {
        final brands = _getBrandOptions();
        if (_selectedPaymentBrand != null && !brands.containsKey(_selectedPaymentBrand)) {
          _selectedPaymentBrand = null;
        }
      }
    });
    if (persist) {
      _persistPaymentMethod(value);
    }
    _updateDraft();
  }

  void _bindDraftListeners() {
    _amountController.addListener(_updateDraft);
    _merchantController.addListener(_updateDraft);
    _locationController.addListener(_updateDraft);
    _noteController.addListener(_updateDraft);
    _paymentLabelController.addListener(_updateDraft);
  }

  void _removeDraftListeners() {
    _amountController.removeListener(_updateDraft);
    _merchantController.removeListener(_updateDraft);
    _locationController.removeListener(_updateDraft);
    _noteController.removeListener(_updateDraft);
    _paymentLabelController.removeListener(_updateDraft);
  }

  void _applyDraft(ExpenseDraft draft) {
    if (draft.amountText != null) {
      _amountController.text = draft.amountText!;
    }
    if (draft.merchant != null) {
      _merchantController.text = draft.merchant!;
    }
    if (draft.locationText != null) {
      _locationController.text = draft.locationText!;
    }
    if (draft.notes != null) {
      _noteController.text = draft.notes!;
    }
    if (draft.paymentLabel != null) {
      _paymentLabelController.text = draft.paymentLabel!;
    }
    if (draft.currencyCode != null) {
      _selectedCurrency = draft.currencyCode!;
    }
    if (draft.categoryId != null) {
      _selectedCategory = draft.categoryId!;
    }
    if (draft.paymentMethodType != null) {
      _selectedPaymentMethod = draft.paymentMethodType!;
    }
    if (draft.paymentBrand != null) {
      _selectedPaymentBrand = draft.paymentBrand;
    }
    if (draft.date != null) {
      _selectedDate = draft.date!;
    }
    _wantsReceipt = draft.hasReceipts;

    if (!_shouldShowPaymentDetails(_selectedPaymentMethod)) {
      _resetPaymentDetails();
    } else {
      final brands = _getBrandOptions();
      if (_selectedPaymentBrand != null && !brands.containsKey(_selectedPaymentBrand)) {
        _selectedPaymentBrand = null;
      }
    }
  }

  ExpenseDraft _buildDraft() {
    return ExpenseDraft(
      amountText: _amountController.text.trim().isEmpty
          ? null
          : _amountController.text.trim(),
      currencyCode: _selectedCurrency,
      categoryId: _selectedCategory,
      date: _selectedDate,
      merchant: _merchantController.text.trim().isEmpty
          ? null
          : _merchantController.text.trim(),
      paymentMethodType: _selectedPaymentMethod,
      paymentBrand: _selectedPaymentBrand,
      paymentLabel: _paymentLabelController.text.trim().isEmpty
          ? null
          : _paymentLabelController.text.trim(),
      locationText: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      notes: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      hasReceipts: _wantsReceipt,
    );
  }

  void _updateDraft() {
    if (widget.expense != null || !_draftUpdatesEnabled) {
      return;
    }

    ref.read(expenseDraftProvider(widget.tripId).notifier).set(_buildDraft());
  }

  void _onPaymentMethodChanged(String value) {
    _setPaymentMethodType(value);
  }

  Map<String, String> _getBrandOptions() {
    if (_selectedPaymentMethod == 'card') {
      return _cardBrands;
    }
    if (_selectedPaymentMethod == 'wallet') {
      return _walletBrands;
    }
    return const {};
  }

  Future<void> _focusAndScroll(GlobalKey targetKey, FocusNode focusNode) async {
    focusNode.requestFocus();
    final targetContext = targetKey.currentContext;
    if (targetContext == null) {
      return;
    }
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 250),
      alignment: 0.2,
    );
  }

  Future<void> _focusFirstInvalid() async {
    final amount = double.tryParse(_amountController.text);
    if (_amountController.text.trim().isEmpty || amount == null || amount <= 0) {
      await _focusAndScroll(_amountFieldKey, _amountFocusNode);
      return;
    }

    if (_selectedCategory.trim().isEmpty) {
      await _focusAndScroll(_categoryFieldKey, _categoryFocusNode);
      return;
    }

    if (_merchantController.text.trim().isEmpty) {
      await _focusAndScroll(_merchantFieldKey, _merchantFocusNode);
      return;
    }
  }

  int _buildReceiptSeed(Receipt receipt) {
    final seedSource = [
      receipt.id,
      receipt.createdAt.millisecondsSinceEpoch.toString(),
      receipt.localPath ?? '',
      receipt.data?.length.toString() ?? '0',
    ].join('|');

    var hash = 0;
    for (final codeUnit in seedSource.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }

    return hash % 100000;
  }

  Future<void> _focusFirstSuggestedField({
    required bool amount,
    required bool merchant,
    required bool date,
    required bool currency,
    required bool location,
    required bool notes,
  }) async {
    if (amount) {
      await _focusAndScroll(_amountFieldKey, _amountFocusNode);
      return;
    }
    if (merchant) {
      await _focusAndScroll(_merchantFieldKey, _merchantFocusNode);
      return;
    }
    if (date) {
      await _focusAndScroll(_dateFieldKey, _dateFocusNode);
      return;
    }
    if (currency) {
      await _focusAndScroll(_currencyFieldKey, _currencyFocusNode);
      return;
    }
    if (location) {
      await _focusAndScroll(_locationFieldKey, _locationFocusNode);
      return;
    }
    if (notes) {
      await _focusAndScroll(_noteFieldKey, _noteFocusNode);
    }
  }

  void _onReceiptSelected(String draftKey, Receipt receipt) {
    if (_selectedReceiptId == receipt.id) {
      return;
    }

    setState(() {
      _selectedReceiptId = receipt.id;
      _showAppliedSuggestionMessage = false;
    });
    ref.read(ocrSuggestionProvider(draftKey).notifier).reset();
  }

  Future<void> _generateOcrSuggestion({
    required String draftKey,
    required Receipt selectedReceipt,
    required int receiptsCount,
  }) async {
    final seed = _buildReceiptSeed(selectedReceipt);
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    await ref.read(ocrSuggestionProvider(draftKey).notifier).generate(
          tripId: widget.tripId,
          draftKey: draftKey,
          receiptsCount: receiptsCount,
          seed: seed,
          currentCurrencyCode: _selectedCurrency,
          currentMerchant: _merchantController.text.trim().isEmpty
              ? null
              : _merchantController.text.trim(),
          currentLocationText: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          currentDate: _selectedDate,
          currentAmount: amount == null || amount <= 0 ? null : amount,
        );
  }

  Future<void> _applySuggestions(OcrSuggestion suggestion) async {
    var amountChanged = false;
    var merchantChanged = false;
    var dateChanged = false;
    var currencyChanged = false;
    var locationChanged = false;
    var notesChanged = false;

    setState(() {
      if (suggestion.amount != null && _amountController.text.trim().isEmpty) {
        _amountController.text = suggestion.amount!.toString();
        amountChanged = true;
      }
      if (suggestion.merchant != null &&
          _merchantController.text.trim().isEmpty) {
        _merchantController.text = suggestion.merchant!;
        merchantChanged = true;
      }
      if (suggestion.date != null) {
        _selectedDate = suggestion.date!;
        dateChanged = true;
      }
      if (suggestion.currencyCode != null) {
        _selectedCurrency = suggestion.currencyCode!;
        currencyChanged = true;
      }
      if (suggestion.locationText != null &&
          _locationController.text.trim().isEmpty) {
        _locationController.text = suggestion.locationText!;
        locationChanged = true;
      }
      if (suggestion.notes != null && _noteController.text.trim().isEmpty) {
        _noteController.text = suggestion.notes!;
        notesChanged = true;
      }
      _showAppliedSuggestionMessage =
          amountChanged || merchantChanged || dateChanged || currencyChanged ||
              locationChanged || notesChanged;
    });

    await _focusFirstSuggestedField(
      amount: amountChanged,
      merchant: merchantChanged,
      date: dateChanged,
      currency: currencyChanged,
      location: locationChanged,
      notes: notesChanged,
    );
    _updateDraft();
  }

  Future<void> _scrollToReceipts() async {
    final targetContext = _receiptsSectionKey.currentContext;
    if (targetContext == null) {
      return;
    }
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 250),
      alignment: 0.1,
    );
  }

  void _addOrUpdateExpense() async {
    final formState = _formKey.currentState;
    if (formState == null) {
      return;
    }

    if (!formState.validate()) {
      await _focusFirstInvalid();
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;

    final shouldPersistPaymentDetails =
      _shouldShowPaymentDetails(_selectedPaymentMethod);
    final paymentMethodBrand = shouldPersistPaymentDetails
      ? _selectedPaymentBrand
      : null;
    final paymentMethodLabel = shouldPersistPaymentDetails
      ? _paymentLabelController.text.trim().isEmpty
        ? null
        : _paymentLabelController.text.trim()
      : null;

    try {
      if (widget.expense != null) {
        // Update existing expense
        final updatedExpense = widget.expense!.copyWith(
          amount: amount,
          currency: _selectedCurrency,
          date: _selectedDate,
          category: _selectedCategory,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          merchant: _merchantController.text.trim(),
          paymentMethod: _selectedPaymentMethod,
          paymentMethodBrand: paymentMethodBrand,
          paymentMethodLabel: paymentMethodLabel,
          locationText: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
        );
        await ref.read(expenseProvider.notifier).updateExpense(
              expense: updatedExpense,
            );

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        // Insert new expense with generated ID
        final newExpenseId = const Uuid().v4();

        await ref.read(expenseProvider.notifier).insertExpense(
              tripId: widget.tripId,
              amount: amount,
              currency: _selectedCurrency,
              date: _selectedDate,
              category: _selectedCategory,
              note: _noteController.text.isEmpty ? null : _noteController.text,
              merchant: _merchantController.text.trim(),
              paymentMethod: _selectedPaymentMethod,
              paymentMethodBrand: paymentMethodBrand,
              paymentMethodLabel: paymentMethodLabel,
              locationText: _locationController.text.trim().isEmpty
                  ? null
                  : _locationController.text.trim(),
              id: newExpenseId, // Use generated ID
            );

        ref.read(expenseDraftProvider(widget.tripId).notifier).clear();

        if (mounted) {
          if (_wantsReceipt) {
            setState(() {
              _newExpenseId = newExpenseId;
            });
            await _scrollToReceipts();
          } else {
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      // No snackbar per UX requirements.
    }
  }

  void _handleParseSms() {
    final input = _smsInputController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _smsParseMessage = 'الرجاء إدخال نص الرسالة أولاً';
      });
      return;
    }

    final result = parseSmsReceipt(input);

    if (!result.isUseful) {
      setState(() {
        _smsParseMessage = 'لم أتمكن من استخراج بيانات مفيدة من النص';
      });
      return;
    }

    // Only fill empty fields
    if (result.amount != null && _amountController.text.trim().isEmpty) {
      _amountController.text = result.amount!.toStringAsFixed(2);
    }

    if (result.currency != null && _selectedCurrency == widget.tripCurrency) {
      setState(() {
        _selectedCurrency = result.currency!;
      });
    }

    if (result.merchant != null && _merchantController.text.trim().isEmpty) {
      _merchantController.text = result.merchant!;
    }

    if (result.dateTime != null) {
      setState(() {
        _selectedDate = result.dateTime!;
      });
    }

    if (result.paymentType != null) {
      final type = result.paymentType!;
      if (_paymentMethods.containsKey(type)) {
        _setPaymentMethodType(type, persist: false);
      }
    }

    if (result.paymentBrand != null) {
      setState(() {
        _selectedPaymentBrand = result.paymentBrand;
      });
    }

    if (result.paymentLabel != null && _paymentLabelController.text.trim().isEmpty) {
      _paymentLabelController.text = result.paymentLabel!;
    }

    _updateDraft();

    // Show success message with confidence
    final confidencePercent = (result.confidence * 100).toStringAsFixed(0);
    setState(() {
      _smsParseMessage = 'تم الاستخراج بنجاح (ثقة: $confidencePercent%)';
    });

    // Focus on first empty critical field
    if (_amountController.text.trim().isEmpty) {
      _amountFocusNode.requestFocus();
    } else if (_merchantController.text.trim().isEmpty) {
      _merchantFocusNode.requestFocus();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _updateDraft();
    }
  }

  Future<void> _handleExit() async {
    if (widget.expense != null) {
      Navigator.pop(context);
      return;
    }

    final draft = ref.read(expenseDraftProvider(widget.tripId));
    if (draft.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final shouldKeepDraft = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حفظ المسودة؟'),
          content: const Text(
            'لديك بيانات غير محفوظة. هل تريد حفظها كمسودة للعودة لاحقًا؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('تجاهل'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldKeepDraft == null) {
      return;
    }

    if (!shouldKeepDraft) {
      ref.read(expenseDraftProvider(widget.tripId).notifier).clear();
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;
    final shouldShowReceipts = isEditing || (_wantsReceipt && _newExpenseId != null);
    final expenseId = _newExpenseId ?? (isEditing ? widget.expense!.id : '');
    final draftKey = expenseId.isEmpty ? 'draft' : expenseId;
    final receiptsAsync = shouldShowReceipts && expenseId.isNotEmpty
      ? ref.watch(watchReceiptsByExpenseProvider(expenseId))
      : const AsyncValue.data(<Receipt>[]);
    final ocrSuggestionAsync = ref.watch(ocrSuggestionProvider(draftKey));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _handleExit();
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
              // Title
              Text(
                isEditing ? 'تعديل مصروف' : 'إضافة مصروف',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // SMS Receipt Parser Card (only in add mode)
              if (!isEditing) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.message, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'استخراج من رسالة SMS',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _smsInputController,
                          decoration: const InputDecoration(
                            hintText: 'الصق نص رسالة البنك هنا...',
                            border: OutlineInputBorder(),
                          ),
                          minLines: 3,
                          maxLines: 6,
                          onChanged: (_) {
                            if (_smsParseMessage != null) {
                              setState(() {
                                _smsParseMessage = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _handleParseSms,
                          icon: const Icon(Icons.auto_fix_high),
                          label: const Text('استخراج البيانات'),
                        ),
                        if (_smsParseMessage != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _smsParseMessage!.contains('بنجاح')
                                  ? Colors.green.withAlpha(50)
                                  : Colors.orange.withAlpha(50),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _smsParseMessage!,
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Amount field
              TextFormField(
                key: _amountFieldKey,
                controller: _amountController,
                focusNode: _amountFocusNode,
                decoration: const InputDecoration(
                  labelText: 'المبلغ',
                  hintText: 'أدخل المبلغ',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'المبلغ مطلوب';
                  }
                  final parsed = double.tryParse(text);
                  if (parsed == null || parsed <= 0) {
                    return 'يرجى إدخال مبلغ صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Currency field
              DropdownButtonFormField<String>(
                key: _currencyFieldKey,
                focusNode: _currencyFocusNode,
                value: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'العملة',
                  prefixIcon: Icon(Icons.currency_exchange),
                ),
                items: ['USD', 'EUR', 'GBP', 'SAR', 'AED', 'KWD', 'QAR']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCurrency = value;
                    });
                    _updateDraft();
                  }
                },
              ),
              const SizedBox(height: 16),

              // Category field
              DropdownButtonFormField<String>(
                key: _categoryFieldKey,
                focusNode: _categoryFocusNode,
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'الفئة',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    _updateDraft();
                  }
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الفئة مطلوبة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date field
              GestureDetector(
                onTap: _pickDate,
                child: Focus(
                  key: _dateFieldKey,
                  focusNode: _dateFocusNode,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'التاريخ',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Merchant field
              TextFormField(
                key: _merchantFieldKey,
                controller: _merchantController,
                focusNode: _merchantFocusNode,
                decoration: const InputDecoration(
                  labelText: 'مكان الشراء',
                  hintText: 'مثال: Starbucks، Uber، Hotel ABC',
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'مكان الشراء مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Payment Method field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.payment, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'طريقة الدفع',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (Theme.of(context).useMaterial3)
                    SegmentedButton<String>(
                      segments: _paymentMethods.entries
                          .map(
                            (entry) => ButtonSegment<String>(
                              value: entry.key,
                              label: Text(entry.value),
                            ),
                          )
                          .toList(),
                      selected: {_selectedPaymentMethod},
                      onSelectionChanged: (selection) {
                        final value = selection.isNotEmpty
                            ? selection.first
                            : _selectedPaymentMethod;
                        _onPaymentMethodChanged(value);
                      },
                    )
                  else
                    Wrap(
                      spacing: 8,
                      children: _paymentMethods.entries
                          .map(
                            (entry) => ChoiceChip(
                              label: Text(entry.value),
                              selected: _selectedPaymentMethod == entry.key,
                              onSelected: (selected) {
                                if (selected) {
                                  _onPaymentMethodChanged(entry.key);
                                }
                              },
                            ),
                          )
                          .toList(),
                    ),
                  if (_shouldShowPaymentDetails(_selectedPaymentMethod)) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentBrand,
                      decoration: const InputDecoration(
                        labelText: 'علامة البطاقة/المحفظة (اختياري)',
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      items: _getBrandOptions()
                          .entries
                          .map((entry) => DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.value),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentBrand = value;
                        });
                        _updateDraft();
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _paymentLabelController,
                      decoration: const InputDecoration(
                        labelText: 'اسم البطاقة/المحفظة (اختياري)',
                        hintText: 'مثال: فرسان الراجحي',
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Location text field
              TextFormField(
                key: _locationFieldKey,
                controller: _locationController,
                focusNode: _locationFocusNode,
                decoration: const InputDecoration(
                  labelText: 'موقع الشراء (اختياري)',
                  hintText: 'مثال: مطار إسطنبول، Taksim، Dubai Mall',
                  prefixIcon: Icon(Icons.place),
                ),
              ),
              const SizedBox(height: 16),

              // Note field
              TextFormField(
                key: _noteFieldKey,
                controller: _noteController,
                focusNode: _noteFocusNode,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                  hintText: 'أضف ملاحظات عن هذا المصروف',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              if (!isEditing) ...[
                Row(
                  children: [
                    Checkbox(
                      value: _wantsReceipt,
                      onChanged: (value) {
                        setState(() {
                          _wantsReceipt = value ?? false;
                        });
                        _updateDraft();
                      },
                    ),
                    const Text('هل يوجد إيصال؟'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'يمكنك إضافته لاحقًا من التعديل.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Receipts section
              if (shouldShowReceipts) ...[
                Text(
                  'الإيصالات',
                  key: _receiptsSectionKey,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ref
                            .read(receiptProvider.notifier)
                            .addReceiptFromCamera(_newExpenseId ?? widget.expense!.id),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('كاميرا'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ref
                            .read(receiptProvider.notifier)
                            .addReceiptFromGallery(_newExpenseId ?? widget.expense!.id),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('معرض'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ReceiptGallery(
                  expenseId: expenseId,
                  isEditing: true,
                  selectedReceiptId: _selectedReceiptId,
                  onReceiptSelected: (receipt) => _onReceiptSelected(draftKey, receipt),
                ),
                const SizedBox(height: 8),
                receiptsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (receipts) {
                    final selectedIndex = receipts.indexWhere(
                      (receipt) => receipt.id == _selectedReceiptId,
                    );
                    if (selectedIndex == -1 && _selectedReceiptId != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) {
                          return;
                        }
                        setState(() {
                          _selectedReceiptId = null;
                          _showAppliedSuggestionMessage = false;
                        });
                        ref.read(ocrSuggestionProvider(draftKey).notifier).reset();
                      });
                    }
                    return Row(
                      children: [
                        const Icon(Icons.receipt_long, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'الإيصال النشط: ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          selectedIndex == -1
                              ? 'غير محدد'
                              : 'رقم ${selectedIndex + 1}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // OCR Mock Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 24,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'استخراج البيانات من الإيصال (تجريبي)',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'سيتم اقتراح المبلغ، التاريخ، العملة، ومكان الشراء بناءً على الإيصال المختار.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        receiptsAsync.when(
                          loading: () => const SizedBox(
                            height: 48,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, _) => Text(
                            'تعذر تحميل الإيصالات: $error',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          data: (receipts) {
                            final hasReceipts = receipts.isNotEmpty;
                            Receipt? selectedReceipt;
                            if (_selectedReceiptId != null) {
                              for (final receipt in receipts) {
                                if (receipt.id == _selectedReceiptId) {
                                  selectedReceipt = receipt;
                                  break;
                                }
                              }
                            }
                            final isGenerateDisabled =
                                !hasReceipts || _selectedReceiptId == null;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasReceipts && _selectedReceiptId == null) ...[
                                  Text(
                                    'اختر إيصالاً أولاً ثم اضغط استخراج.',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.orange[700],
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: isGenerateDisabled || selectedReceipt == null
                                        ? null
                                        : () async {
                                            setState(() {
                                              _showAppliedSuggestionMessage = false;
                                            });
                                            await _generateOcrSuggestion(
                                              draftKey: draftKey,
                                              selectedReceipt: selectedReceipt!,
                                              receiptsCount: receipts.length,
                                            );
                                          },
                                    icon: const Icon(Icons.document_scanner_outlined),
                                    label: const Text('استخراج البيانات (تجريبي)'),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ocrSuggestionAsync.when(
                                  loading: () => const LinearProgressIndicator(),
                                  error: (error, _) => Text(
                                    error.toString(),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.red[700],
                                        ),
                                  ),
                                  data: (suggestion) {
                                    if (suggestion == null) {
                                      return Text(
                                        'هذه الميزة ستعمل كاقتراحات، وستراجعها قبل الحفظ.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.grey[600]),
                                      );
                                    }

                                    final hasSuggestions = suggestion.hasAnyValue;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (!hasSuggestions)
                                          Text(
                                            'لا توجد اقتراحات جديدة لأن الحقول ممتلئة.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(color: Colors.grey[600]),
                                          )
                                        else ...[
                                          if (suggestion.amount != null)
                                            Text('المبلغ المقترح: ${suggestion.amount}'),
                                          if (suggestion.merchant != null)
                                            Text('مكان الشراء المقترح: ${suggestion.merchant}'),
                                          if (suggestion.date != null)
                                            Text(
                                              'التاريخ المقترح: '
                                              '${suggestion.date!.year}-'
                                              '${suggestion.date!.month.toString().padLeft(2, '0')}-'
                                              '${suggestion.date!.day.toString().padLeft(2, '0')}',
                                            ),
                                          if (suggestion.currencyCode != null)
                                            Text('العملة المقترحة: ${suggestion.currencyCode}'),
                                          if (suggestion.locationText != null)
                                            Text('الموقع المقترح: ${suggestion.locationText}'),
                                          if (suggestion.notes != null)
                                            Text('الملاحظات المقترحة: ${suggestion.notes}'),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            width: double.infinity,
                                            child: OutlinedButton.icon(
                                              onPressed: hasSuggestions
                                                  ? () => _applySuggestions(suggestion)
                                                  : null,
                                              icon: const Icon(Icons.check_circle_outline),
                                              label: const Text('تطبيق الاقتراحات'),
                                            ),
                                          ),
                                        ],
                                        if (_showAppliedSuggestionMessage) ...[
                                          const SizedBox(height: 12),
                                          Text(
                                            'تم تطبيق اقتراحات الإيصال المختار. راجعها قبل الحفظ.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(color: Colors.green[700]),
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ] else
                const SizedBox(height: 12),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _handleExit,
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _newExpenseId != null
                          ? () => Navigator.pop(context)
                          : _addOrUpdateExpense,
                      child: Text(
                        _newExpenseId != null
                            ? 'إضافة'
                            : (isEditing ? 'تحديث' : 'إضافة'),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
