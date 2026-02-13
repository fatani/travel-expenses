import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/db/db_providers.dart';
import '../../../../core/models/receipt.dart';
import '../../data/receipt_storage.dart';

final receiptStorageProvider = Provider((ref) => ReceiptStorage());

final imagePickerProvider = Provider((ref) => ImagePicker());

/// Watch all receipts for a specific expense
final watchReceiptsByExpenseProvider =
    StreamProvider.autoDispose.family<List<Receipt>, String>(
  (ref, expenseId) {
    final repository = ref.watch(repositoryProvider);
    return repository.watchReceiptsByExpense(expenseId);
  },
);

class ReceiptNotifier extends StateNotifier<AsyncValue<void>> {
  final ReceiptStorage storage;
  final ImagePicker picker;

  ReceiptNotifier({
    required this.storage,
    required this.picker,
  }) : super(const AsyncValue.data(null));

  Future<void> addReceiptFromCamera(String expenseId) async {
    state = const AsyncValue.loading();
    try {
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        await _processAndSaveReceipt(expenseId, File(image.path));
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addReceiptFromGallery(String expenseId) async {
    state = const AsyncValue.loading();
    try {
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _processAndSaveReceipt(expenseId, File(image.path));
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _processAndSaveReceipt(String expenseId, File imageFile) async {
    // Save image to local storage
    await storage.saveReceiptImage(expenseId, imageFile);
    // Image saved successfully - repository insert handled by UI layer
  }

  String? getLastSavedPath() {
    // Placeholder - actual path returned from _processAndSaveReceipt
    return null;
  }
}

final receiptProvider =
    StateNotifierProvider<ReceiptNotifier, AsyncValue<void>>((ref) {
  final storage = ref.watch(receiptStorageProvider);
  final picker = ref.watch(imagePickerProvider);
  return ReceiptNotifier(storage: storage, picker: picker);
});

/// Provider for calling repository delete
final deleteReceiptProvider =
    FutureProvider.autoDispose.family<void, (String, String)>((ref, _) {
  // Async operation will be handled in UI
  return Future<void>.value();
});
