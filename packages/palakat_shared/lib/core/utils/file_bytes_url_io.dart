import 'dart:io';
import 'dart:typed_data';

Future<String> bytesToUrl({
  required Uint8List bytes,
  required String filename,
  String? contentType,
}) async {
  final safe = filename.trim().isEmpty
      ? 'file'
      : filename.trim().replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final dir = await Directory.systemTemp.createTemp('palakat_');
  final file = File(
    '${dir.path}/$stamp'
    '_'
    '$safe',
  );
  await file.writeAsBytes(bytes, flush: true);
  return file.uri.toString();
}
