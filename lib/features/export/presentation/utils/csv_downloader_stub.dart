import 'dart:typed_data';

import 'csv_downloader.dart';

/// Stub implementation for non-web platforms (mobile, desktop).
/// Returns null since direct file download is not supported without additional plugins.
class StubCsvDownloader implements CsvDownloader {
  @override
  Future<String?> downloadBytes({
    required Uint8List bytes,
    required String filename,
  }) async {
    // Not supported on mobile/desktop without additional plugins
    return null;
  }
}

/// Factory function for conditional imports.
CsvDownloader createCsvDownloaderImpl() => StubCsvDownloader();
