import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/csv_export_service.dart';

final csvExportServiceProvider = Provider((ref) {
  return CsvExportService();
});
