import 'package:freezed_annotation/freezed_annotation.dart';

import 'date_time_converter.dart';

part 'location.freezed.dart';

part 'location.g.dart';

@freezed
abstract class Location with _$Location {
  const factory Location({
    required int id,
    required double latitude,
    required double longitude,
    required String name,
    @DateTimeConverterTimestamp() DateTime? createdAt,
    @DateTimeConverterTimestamp() DateTime? updatedAt,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> data) =>
      _$LocationFromJson(data);
}
