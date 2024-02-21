// import 'dart:convert';
// import 'dart:io';
//
// import 'package:file_picker/file_picker.dart';
//
// class FilePickerUtil {
//   static Future<File?> pickFile({bool imagesOnly = false}) async {
//     FilePickerResult? result;
//
//     result = await FilePicker.platform.pickFiles(
//       type: imagesOnly ? FileType.image : FileType.any,
//     );
//
//     if (result == null) {
//       return null;
//     }
//
//     return File(result.files.single.path!);
//   }
//
//   static Future<String?> fileToBase64(File file) async {
//     if (!file.path.contains(".")) {
//       return null;
//     }
//     final fileExtension = file.path.split(".").last;
//     final unsigned = await file.readAsBytes();
//     final rawB64 = base64Encode(unsigned);
//
//     return "data:image/$fileExtension;base64, $rawB64";
//   }
// }
