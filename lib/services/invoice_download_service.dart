import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'api_routes.dart';
import 'cookie_manager.dart';

class InvoiceDownloadService {
  /// Downloads invoice PDF for the given paymentId and saves to Downloads folder.
  /// Returns the saved file path on success, throws on failure.
  static Future<String> downloadInvoice(String paymentId) async {
    // Request storage permission on Android < 13
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkVersion();
      if (sdkInt < 33) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission denied');
        }
      }
    }

    final headers = await CookieManager.getHeadersWithCookie();
    final url = ApiConfig.downloadInvoice(paymentId);

    print("📥 Downloading invoice from: $url");

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to download invoice (HTTP ${response.statusCode})');
    }

    final bytes = response.bodyBytes;
    final fileName = 'invoice_$paymentId.pdf';
    final filePath = await _getSavePath(fileName);

    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    print("✅ Invoice saved to: $filePath");
    return filePath;
  }

  /// Opens the downloaded invoice file.
  static Future<void> openFile(String filePath) async {
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      throw Exception('Could not open file: ${result.message}');
    }
  }

  static Future<String> _getSavePath(String fileName) async {
    if (Platform.isAndroid) {
      // Use the public Downloads directory
      final dir = Directory('/storage/emulated/0/Download');
      if (await dir.exists()) {
        return '${dir.path}/$fileName';
      }
    }
    // Fallback: app documents directory (also works for iOS)
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$fileName';
  }

  static Future<int> _getAndroidSdkVersion() async {
    try {
      final result = await Process.run('getprop', ['ro.build.version.sdk']);
      return int.tryParse(result.stdout.toString().trim()) ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
