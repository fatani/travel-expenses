import 'dart:html' as html;
import 'dart:typed_data';

import 'csv_downloader.dart';

/// Web implementation for CSV download using dart:html.
/// Uses Blob and AnchorElement to trigger browser download.
class WebCsvDownloader implements CsvDownloader {
  @override
  Future<String?> downloadBytes({
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      // Create a Blob from the bytes
      final blob = html.Blob([bytes], 'text/csv;charset=utf-8');

      // Create a URL for the blob
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create an anchor element and trigger download
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..style.display = 'none';

      // Append to body, click, and remove
      html.document.body!.append(anchor);
      anchor.click();
      anchor.remove();

      // Revoke the URL to free memory
      html.Url.revokeObjectUrl(url);

      return filename;
    } catch (e) {
      // Return null on error
      return null;
    }
  }
}

/// Factory function for conditional imports.
CsvDownloader createCsvDownloaderImpl() => WebCsvDownloader();
