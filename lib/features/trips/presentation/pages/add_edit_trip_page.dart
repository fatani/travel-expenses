import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/trip.dart';
import '../providers/trips_providers.dart';

class AddEditTripPage extends ConsumerStatefulWidget {
  final String? tripId;

  const AddEditTripPage({
    super.key,
    this.tripId,
  });

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
  bool _initializedFromTrip = false;
  Trip? _editingTrip;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _initializeFromTrip(Trip trip) {
    _nameController.text = trip.name;
    _selectedCurrency = trip.defaultCurrency;
    _startDate = trip.startDate;
    _endDate = trip.endDate;
    _editingTrip = trip;
    _initializedFromTrip = true;
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
      if (widget.tripId == null) {
        await ref.read(addTripProvider.notifier).addTrip(
          name: _nameController.text,
          defaultCurrency: _selectedCurrency!,
          startDate: _startDate,
          endDate: _endDate,
        );
      } else if (_editingTrip != null) {
        await ref.read(updateTripProvider.notifier).updateTrip(
          id: _editingTrip!.id,
          name: _nameController.text,
          defaultCurrency: _selectedCurrency!,
          startDate: _startDate,
          endDate: _endDate,
          createdAt: _editingTrip!.createdAt,
        );
      }

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
    final isEditing = widget.tripId != null;
    final tripAsync = isEditing ? ref.watch(tripByIdProvider(widget.tripId!)) : null;

    if (isEditing && !_initializedFromTrip) {
      tripAsync?.whenData((trip) {
        if (trip == null || _initializedFromTrip) {
          return;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _initializedFromTrip) {
            return;
          }
          setState(() {
            _initializeFromTrip(trip);
          });
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'تعديل رحلة' : 'إضافة رحلة'),
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
                      : Text(isEditing ? 'تحديث الرحلة' : 'حفظ الرحلة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
