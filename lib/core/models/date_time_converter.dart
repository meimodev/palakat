import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

class DateTimeConverterTimestamp implements JsonConverter<DateTime, dynamic> {
  const DateTimeConverterTimestamp();

  @override
  DateTime fromJson(dynamic json) {
    if (json.runtimeType == Timestamp) {
      final data = json as Timestamp;
      return data.toDate();
    }
    return (json as DateTime);
  }

  @override
  dynamic toJson(DateTime data) => Timestamp.fromDate(data).toString();
}
