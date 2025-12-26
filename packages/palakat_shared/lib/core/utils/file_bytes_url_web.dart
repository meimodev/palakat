import 'dart:typed_data';

import 'dart:core';

Future<String> bytesToUrl({
  required Uint8List bytes,
  required String filename,
  String? contentType,
}) async {
  final uri = Uri.dataFromBytes(
    bytes,
    mimeType: contentType ?? 'application/octet-stream',
  );
  return uri.toString();
}
