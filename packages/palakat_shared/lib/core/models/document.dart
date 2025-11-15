import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/models/church.dart';
import 'package:palakat_shared/core/models/file_manager.dart';

part 'document.freezed.dart';

part 'document.g.dart';

@freezed
abstract class Document with _$Document {
  const factory Document({
    int? id,
    required String name,
    required String accountNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    required int churchId,
    Church? church,
    int? fileId,
    FileManager? file,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);
}

@freezed
abstract class DocumentSettings with _$DocumentSettings {
  const factory DocumentSettings({required String identityNumberTemplate}) =
      _DocumentSettings;

  factory DocumentSettings.fromJson(Map<String, dynamic> json) =>
      _$DocumentSettingsFromJson(json);
}
