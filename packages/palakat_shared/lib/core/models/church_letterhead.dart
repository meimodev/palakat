import 'package:freezed_annotation/freezed_annotation.dart';

import 'file_manager.dart';

part 'church_letterhead.freezed.dart';
part 'church_letterhead.g.dart';

@freezed
abstract class ChurchLetterhead with _$ChurchLetterhead {
  const factory ChurchLetterhead({
    int? id,
    required int churchId,
    int? logoFileId,
    FileManager? logoFile,
    String? title,
    String? line1,
    String? line2,
    String? line3,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ChurchLetterhead;

  factory ChurchLetterhead.fromJson(Map<String, dynamic> json) =>
      _$ChurchLetterheadFromJson(json);
}
