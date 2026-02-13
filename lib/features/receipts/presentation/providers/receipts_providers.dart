import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

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
  final Ref ref;

  ReceiptNotifier({
    required this.storage,
    required this.picker,
    required this.ref,
  }) : super(const AsyncValue.data(null));

  Future<void> addReceiptFromCamera(String expenseId) async {
    state = const AsyncValue.loading();
    try {
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        await _processAndSaveReceipt(expenseId, File(image.path));
        state = const AsyncValue.data(null);
      } else {
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
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _processAndSaveReceipt(String expenseId, File imageFile) async {
    // 1. Save image to local storage
    final localPath = await storage.saveReceiptImage(expenseId, imageFile);

    // 2. Create receipt record with UUID
    final receipt = Receipt(
      id: const Uuid().v4(),
      expenseId: expenseId,
      localPath: localPath,
      createdAt: DateTime.now(),
    );

    // 3. Insert into database
    final repository = ref.read(repositoryProvider);
    await repository.insertReceipt(receipt);
  }
}

final receiptProvider =
    StateNotifierProvider<ReceiptNotifier, AsyncValue<void>>((ref) {
  final storage = ref.watch(receiptStorageProvider);
  final picker = ref.watch(imagePickerProvider);
  return ReceiptNotifier(storage: storage, picker: picker, ref: ref);
});

/// Provider for calling repository delete
final deleteReceiptProvider =
    FutureProvider.autoDispose.family<void, (String, String)>((ref, _) {
  return Future<void>.value();
});
