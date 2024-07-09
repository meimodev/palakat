// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat/core/models/models.dart';

part 'column.freezed.dart';

part 'column.g.dart';

@freezed
class Column with _$Column {
  const factory Column({
    @Default('') String serial,
    @Default('') String name,
    @JsonKey(name: "church_serial") @Default('') String churchSerial,
    Church? church,
  }) = _Column;

  factory Column.fromJson(Map<String, dynamic> data) => _$ColumnFromJson(data);
}
