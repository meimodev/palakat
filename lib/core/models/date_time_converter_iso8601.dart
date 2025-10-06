import 'package:freezed_annotation/freezed_annotation.dart';

class DateTimeConverterIso8601 implements JsonConverter<DateTime?, String?> {
  const DateTimeConverterIso8601();

  @override
  DateTime? fromJson(String? timestamp) {
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  @override
  String? toJson(DateTime? dateTime) {
    return dateTime?.toUtc().toIso8601String();
  }
}
