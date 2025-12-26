import 'dart:typed_data';

import 'package:palakat_shared/core/models/result.dart';

Future<String> bytesToUrl({
  required Uint8List bytes,
  required String filename,
  String? contentType,
}) async {
  throw Failure('Unsupported platform');
}
