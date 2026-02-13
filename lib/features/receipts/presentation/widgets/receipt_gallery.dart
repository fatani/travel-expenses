import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/db_providers.dart';
import '../../../../core/models/receipt.dart';
import '../providers/receipts_providers.dart';

class ReceiptGallery extends ConsumerWidget {
  final String expenseId;
  final bool isEditing;

  const ReceiptGallery({
    super.key,
    required this.expenseId,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SizedBox(
          height: 80,
          child: Center(
            child: Text(
              'احفظ المصروف أولاً لإضافة إيصالات',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final receiptsAsync = ref.watch(watchReceiptsByExpenseProvider(expenseId));

    return receiptsAsync.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, st) => SizedBox(
        height: 80,
        child: Center(child: Text('خطأ: $error')),
      ),
      data: (receipts) {
        if (receipts.isEmpty) {
          return const SizedBox(
            height: 80,
            child: Center(
              child: Text('لا توجد إيصالات'),
            ),
          );
        }

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: receipts.length,
            itemBuilder: (context, index) {
              final receipt = receipts[index];
              return _ReceiptThumbnail(
                receipt: receipt,
                expenseId: expenseId,
              );
            },
          ),
        );
      },
    );
  }
}

class _ReceiptThumbnail extends ConsumerWidget {
  final Receipt receipt;
  final String expenseId;

  const _ReceiptThumbnail({
    required this.receipt,
    required this.expenseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _showFullImage(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(receipt.localPath),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showDeleteConfirmation(context, ref),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.file(
              File(receipt.localPath),
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف الإيصال'),
          content: const Text('هل أنت متأكد من حذف هذا الإيصال؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Delete from storage
                  final storage = ref.read(receiptStorageProvider);
                  await storage.deleteReceiptFile(receipt.localPath);

                  // Delete from database
                  final repository = ref.read(repositoryProvider);
                  await repository.deleteReceipt(receipt.id);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف الإيصال')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ: $e')),
                    );
                  }
                }
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }
}
