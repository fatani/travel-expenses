import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../expenses/presentation/providers/expenses_providers.dart';
import '../../providers/trip_csv_export_provider.dart';
import '../utils/csv_downloader.dart';

/// Export tab for trip details page.
/// Allows users to download trip expenses as CSV.
class TripExportTab extends ConsumerStatefulWidget {
  final String tripId;

  const TripExportTab({
    required this.tripId,
    super.key,
  });

  @override
  ConsumerState<TripExportTab> createState() => _TripExportTabState();
}

class _TripExportTabState extends ConsumerState<TripExportTab> {
  bool _isLoading = false;
  String? _message;

  Future<void> _handleExport() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // Get CSV bytes from provider
      final csvBytes = await ref.read(tripCsvExportProvider(widget.tripId).future);

      // Get filename from provider
      final filename = await ref.read(csvExportFilenameProvider(widget.tripId).future);

      // Create downloader and download
      final downloader = createCsvDownloader();
      final result = await downloader.downloadBytes(
        bytes: csvBytes,
        filename: filename,
      );

      if (mounted) {
        setState(() {
          if (result != null) {
            _message = 'تم تنزيل الملف: $result';
          } else if (!kIsWeb) {
            _message = 'التنزيل المباشر متاح على الويب حاليًا.';
          } else {
            _message = 'تعذر إنشاء الملف';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[ERR][export][csv_export]: $e');
      if (mounted) {
        setState(() {
          _message = 'تعذر إنشاء الملف';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(watchExpensesByTripProvider(widget.tripId));

    return expensesAsync.when(
      loading: () => const AppLoading(),
      error: (error, stackTrace) {
        debugPrint('[ERR][export][expenses_list]: $error');
        debugPrint('$stackTrace');
        return AppErrorState(
          title: 'تعذر تحميل المصاريف',
          message: 'حدث خطأ غير متوقع. يمكنك المحاولة مرة أخرى.',
          onRetry: () => ref.invalidate(watchExpensesByTripProvider(widget.tripId)),
        );
      },
      data: (expenses) {
        final isEmpty = expenses.isEmpty;
        final statusMessage = isEmpty ? 'لا توجد مصاريف لتصديرها.' : _message;

        if (isEmpty) {
          return AppEmptyState(
            icon: Icons.download,
            title: 'لا توجد مصاريف لتصديرها',
            message: 'أضف مصاريف لتتمكن من تصديرها.',
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تصدير البيانات',
                        style: Theme.of(context).textTheme.titleLarge,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'سيتم تصدير جميع مصاريف الرحلة بصيغة CSV.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'يشمل: التاريخ، المبلغ، العملة، الفئة، مكان الشراء، طريقة الدفع، الملاحظات، وعدد الإيصالات.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Export button
              ElevatedButton(
                onPressed: _isLoading || isEmpty ? null : _handleExport,
                child: const Text('تصدير CSV'),
              ),
              if (_isLoading) ...[
                const SizedBox(height: 12.0),
                Text(
                  'جارٍ تجهيز ملف CSV…',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
              const SizedBox(height: 16.0),

              // Status message
              if (statusMessage != null)
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: statusMessage.contains('خطأ') ||
                            statusMessage.contains('تعذر')
                        ? Colors.red[50]
                        : Colors.green[50],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: statusMessage.contains('خطأ') ||
                              statusMessage.contains('تعذر')
                          ? Colors.red[200]!
                          : Colors.green[200]!,
                    ),
                  ),
                  child: Text(
                    statusMessage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: statusMessage.contains('خطأ') ||
                                  statusMessage.contains('تعذر')
                              ? Colors.red[800]
                              : Colors.green[800],
                        ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
