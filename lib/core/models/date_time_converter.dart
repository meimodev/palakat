import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class DateTimeConverterTimestamp implements JsonConverter<DateTime, dynamic> {
  const DateTimeConverterTimestamp();

  @override
  DateTime fromJson(dynamic json) {
    if (json == null) {
      return DateTime.now();
    }
    try {
      if (json.runtimeType == Timestamp) {
        final data = json as Timestamp;
        return data.toDate();
      } else if (json is String) {
        return DateTime.parse(json);
      } else if (json is DateTime) {
        return json;
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  dynamic toJson(DateTime data) {
    return Timestamp.fromDate(data).toString();
  }
}
