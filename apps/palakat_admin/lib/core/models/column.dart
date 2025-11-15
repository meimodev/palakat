import 'package:freezed_annotation/freezed_annotation.dart';

part 'column.freezed.dart';

part 'column.g.dart';

@freezed
abstract class Column with _$Column {
  const factory Column({
    int? id,
    required String name,
    DateTime? createdAt,
    DateTime? updatedAt,
    required int churchId,
  }) = _Column;

  factory Column.fromJson(Map<String, dynamic> json) => _$ColumnFromJson(json);
}
