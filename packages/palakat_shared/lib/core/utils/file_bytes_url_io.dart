import 'dart:io';
import 'dart:typed_data';

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

Future<String> bytesToUrl({
  required Uint8List bytes,
  required String filename,
  String? contentType,
}) async {
  final safe = filename.trim().isEmpty
      ? 'file'
      : _sanitizeFilename(filename.trim());
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
