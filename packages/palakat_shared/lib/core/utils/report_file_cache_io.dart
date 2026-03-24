import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

String _sanitizeFilename(String value) {
  final buffer = StringBuffer();
  for (final codeUnit in value.codeUnits) {
    final isUppercase = codeUnit >= 65 && codeUnit <= 90;
    final isLowercase = codeUnit >= 97 && codeUnit <= 122;
    final isDigit = codeUnit >= 48 && codeUnit <= 57;
    final isAllowedSymbol = codeUnit == 46 || codeUnit == 95 || codeUnit == 45;
    buffer.writeCharCode(
      isUppercase || isLowercase || isDigit || isAllowedSymbol ? codeUnit : 95,
    );
  }
  return buffer.toString();
}

String _fileExtension(String filename) {
  final dotIndex = filename.lastIndexOf('.');
  if (dotIndex <= 0 || dotIndex >= filename.length - 1) {
    return '';
  }
  return filename.substring(dotIndex);
}

Future<String> storeReportFile({
  required Uint8List bytes,
  required int reportId,
  required String filename,
  String? contentType,
}) async {
  final safeFilename = filename.trim().isEmpty
      ? 'report'
      : _sanitizeFilename(filename.trim());
  final extension = _fileExtension(safeFilename);
  final directory = await getApplicationSupportDirectory();
  final reportDirectory = Directory('${directory.path}/report_cache');
  await reportDirectory.create(recursive: true);
  final file = File(
    '${reportDirectory.path}/report_$reportId'
    '${extension.isEmpty ? '' : extension}',
  );
  await file.writeAsBytes(bytes, flush: true);
  return file.uri.toString();
}

Future<bool> reportFileExists(String uri) async {
  if (uri.trim().isEmpty) {
    return false;
  }
  try {
    final file = File.fromUri(Uri.parse(uri));
    return file.exists();
  } catch (_) {
    return false;
  }
}

Future<void> deleteStoredReportFile(String uri) async {
  if (uri.trim().isEmpty) {
    return;
  }
  try {
    final file = File.fromUri(Uri.parse(uri));
    if (await file.exists()) {
      await file.delete();
    }
  } catch (_) {}
}
