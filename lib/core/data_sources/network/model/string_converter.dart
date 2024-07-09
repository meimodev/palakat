import 'package:freezed_annotation/freezed_annotation.dart';

class StringConverter implements JsonConverter<String?, String?> {
  const StringConverter();

  @override
  String? fromJson(String? string) {
    return string;
  }

  @override
  String? toJson(String? string) =>
      string != null && string.isNotEmpty ? string : null;
}
