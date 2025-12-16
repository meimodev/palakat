import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_manager.freezed.dart';
part 'file_manager.g.dart';

enum FileProvider {
  @JsonValue('FIREBASE_STORAGE')
  firebaseStorage,
}

@freezed
abstract class FileManager with _$FileManager {
  const factory FileManager({
    int? id,
    @Default(FileProvider.firebaseStorage) FileProvider provider,
    String? bucket,
    String? path,
    @Default(0) double sizeInKB,
    String? contentType,
    String? originalName,
    int? churchId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FileManager;

  factory FileManager.fromJson(Map<String, dynamic> json) =>
      _$FileManagerFromJson(json);
}
