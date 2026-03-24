import 'dart:typed_data';

Future<String> storeReportFile({
  required Uint8List bytes,
  required int reportId,
  required String filename,
  String? contentType,
}) async {
  return Uri.dataFromBytes(
    bytes,
    mimeType: contentType ?? 'application/octet-stream',
  ).toString();
}

Future<bool> reportFileExists(String uri) async {
  return uri.trim().isNotEmpty;
}

Future<void> deleteStoredReportFile(String uri) async {}
