import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/currencies_provider.dart';

class AddCurrencyBottomSheet extends ConsumerStatefulWidget {
  final ValueChanged<String?>? onCurrencyAdded;

  const AddCurrencyBottomSheet({
    super.key,
    this.onCurrencyAdded,
  });

  @override
  ConsumerState<AddCurrencyBottomSheet> createState() => _AddCurrencyBottomSheetState();
}

class _AddCurrencyBottomSheetState extends ConsumerState<AddCurrencyBottomSheet> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  Future<void> _handleAddCurrency() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(addCurrencyProvider.notifier).addCurrency(
            code: _codeController.text,
            name: _nameController.text,
            symbol: _symbolController.text,
          );

      // Check for errors after adding
      final state = ref.read(addCurrencyProvider);
      if (state.isLoading) {
        return; // Still loading
      }

      if (state.hasError) {
        // Error occurred
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          // Display error below fields
          _showErrorMessage(state.error.toString());
        }
        return;
      }

      // Success: notify caller with the added currency code, then close
      if (mounted) {
        final addedCode = _codeController.text.toUpperCase().trim();
        widget.onCurrencyAdded?.call(addedCode);
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider errors
    ref.listen(addCurrencyProvider, (previous, next) {
      if (next.hasError && mounted) {
        _showErrorMessage(next.error.toString());
      }
    });

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'إضافة عملة جديدة',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Code field
              TextFormField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'رمز العملة',
                  hintText: 'مثال: SAR',
                  border: OutlineInputBorder(),
                  helperText: 'يجب أن يكون بين 2 و 5 أحرف (بدون مسافات)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'رمز العملة مطلوب';
                  }
                  if (value.contains(' ')) {
                    return 'لا تستخدم مسافات';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Name field
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'اسم العملة',
                  hintText: 'مثال: ريال قطري',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'اسم العملة مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Symbol field
              TextFormField(
                controller: _symbolController,
                maxLength: 2,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'رمز العملة (اختياري)',
                  hintText: 'مثال: ﷼',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length > 2) {
                    return 'يجب أن يكون الرمز حرف أو رمز واحد أو اثنين';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleAddCurrency,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('حفظ العملة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
