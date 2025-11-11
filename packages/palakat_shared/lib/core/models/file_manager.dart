import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_manager.freezed.dart';
part 'file_manager.g.dart';

@freezed
abstract class FileManager with _$FileManager {
  const factory FileManager({
    int? id,
    @Default(0) double sizeInKB,
    required String url,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FileManager;

  factory FileManager.fromJson(Map<String, dynamic> json) => _$FileManagerFromJson(json);
}
