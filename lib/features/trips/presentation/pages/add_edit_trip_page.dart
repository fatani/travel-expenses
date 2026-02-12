import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/trips_providers.dart';

class AddEditTripPage extends ConsumerStatefulWidget {
  const AddEditTripPage({super.key});

  @override
  ConsumerState<AddEditTripPage> createState() => _AddEditTripPageState();
}

class _AddEditTripPageState extends ConsumerState<AddEditTripPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedCurrency = 'SAR';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_endDate != null && _startDate != null && _endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تاريخ الانتهاء يجب أن يكون بعد تاريخ البداية')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(addTripProvider.notifier).addTrip(
        name: _nameController.text,
        defaultCurrency: _selectedCurrency!,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة رحلة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اسم الرحلة
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الرحلة',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الاسم مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // العملة الافتراضية
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'العملة الافتراضية',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'SAR', child: Text('SAR (ريال سعودي)')),
                  DropdownMenuItem(value: 'USD', child: Text('USD (دولار أمريكي)')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR (يورو)')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'اختر العملة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // تاريخ البداية
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _startDate == null
                          ? 'تاريخ البداية (اختياري)'
                          : 'تاريخ البداية: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, true),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // تاريخ الانتهاء
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _endDate == null
                          ? 'تاريخ الانتهاء (اختياري)'
                          : 'تاريخ الانتهاء: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context, false),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // زر الحفظ
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('حفظ الرحلة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
