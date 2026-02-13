import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Result of saving a receipt image
class SaveReceiptResult {
  final String? localPath; // For Mobile/Desktop
  final Uint8List? data; // For Web

  SaveReceiptResult({this.localPath, this.data});
}

class ReceiptStorage {
  /// Save receipt image and return appropriate result based on platform
  Future<SaveReceiptResult> saveReceiptImage(
    String expenseId,
    XFile imageFile,
  ) async {
    if (kIsWeb) {
      // Web: Store as bytes (no file system)
      final bytes = await imageFile.readAsBytes();
      return SaveReceiptResult(data: bytes);
    } else {
      // Mobile/Desktop: Store as file
      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory(p.join(appDir.path, 'receipts', expenseId));
      
      if (!await receiptsDir.exists()) {
        await receiptsDir.create(recursive: true);
      }

      // Generate unique filename
      final extension = p.extension(imageFile.name);
      final filename = '${const Uuid().v4()}$extension';
      final savedPath = p.join(receiptsDir.path, filename);

      // Copy file
      final bytes = await imageFile.readAsBytes();
      await File(savedPath).writeAsBytes(bytes);

      return SaveReceiptResult(localPath: savedPath);
    }
  }

  /// Delete receipt file from storage (Mobile/Desktop only)
  Future<void> deleteReceiptFile(String? localPath) async {
    if (localPath == null || kIsWeb) return;

    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Silent failure
    }
  }

  /// Get all receipt files in expense directory (Mobile/Desktop only)
  Future<List<File>> getReceiptFilesForExpense(String expenseId) async {
    if (kIsWeb) return [];

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final expenseDir = Directory(p.join(appDir.path, 'receipts', expenseId));
      
      if (!await expenseDir.exists()) return [];
      
      final files = expenseDir.listSync();
      return files.whereType<File>().toList();
    } catch (e) {
      return [];
    }
  }

  /// Clean up empty expense directories (Mobile/Desktop only)
  Future<void> cleanupEmptyExpenseDir(String expenseId) async {
    if (kIsWeb) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final expenseDir = Directory(p.join(appDir.path, 'receipts', expenseId));
      
      if (!await expenseDir.exists()) return;
      
      final files = await expenseDir.list().toList();
      if (files.isEmpty) {
        await expenseDir.delete();
      }
    } catch (e) {
      // Silent failure
    }
  }
}
