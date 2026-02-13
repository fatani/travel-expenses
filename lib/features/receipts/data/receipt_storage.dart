import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ReceiptStorage {
  /// Get or create receipts directory
  Future<Directory> _getReceiptsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory(p.join(appDir.path, 'receipts'));
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }
    return receiptsDir;
  }

  /// Get or create expense-specific subdirectory
  Future<Directory> _getExpenseDir(String expenseId) async {
    final receiptsDir = await _getReceiptsDir();
    final expenseDir = Directory(p.join(receiptsDir.path, expenseId));
    if (!await expenseDir.exists()) {
      await expenseDir.create(recursive: true);
    }
    return expenseDir;
  }

  /// Copy image file to receipt storage and return local path
  Future<String> saveReceiptImage(String expenseId, File imageFile) async {
    final expenseDir = await _getExpenseDir(expenseId);
    
    // Generate unique filename with UUID
    final extension = p.extension(imageFile.path);
    final filename = '${const Uuid().v4()}$extension';
    
    final savedPath = p.join(expenseDir.path, filename);
    await imageFile.copy(savedPath);
    
    return savedPath;
  }

  /// Delete receipt file from storage
  Future<void> deleteReceiptFile(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Silent failure - file may already be deleted
    }
  }

  /// Get all receipt files in expense directory (for verification)
  Future<List<File>> getReceiptFilesForExpense(String expenseId) async {
    try {
      final expenseDir = await _getExpenseDir(expenseId);
      final files = expenseDir.listSync();
      return files.whereType<File>().toList();
    } catch (e) {
      // Silent failure - directory may not exist
      return [];
    }
  }

  /// Clean up empty expense directories
  Future<void> cleanupEmptyExpenseDir(String expenseId) async {
    try {
      final expenseDir = await _getExpenseDir(expenseId);
      final files = await expenseDir.list().toList();
      if (files.isEmpty) {
        await expenseDir.delete();
      }
    } catch (e) {
      // Silent failure - directory cleanup not critical
    }
  }
}
