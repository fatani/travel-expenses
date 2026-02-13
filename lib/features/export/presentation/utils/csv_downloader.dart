import 'dart:typed_data';

import 'csv_downloader_stub.dart'
    if (dart.library.html) 'csv_downloader_web.dart';

/// Abstract downloader for CSV files.
/// Supports web (actual download) and mobile (stub/unsupported).
abstract class CsvDownloader {
  /// Download CSV bytes as a file.
  /// Returns the filename if successful, null otherwise.
  Future<String?> downloadBytes({
    required Uint8List bytes,
    required String filename,
  });
}

/// Factory to create the appropriate downloader for the current platform.
CsvDownloader createCsvDownloader() => createCsvDownloaderImpl();
