import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'autocomplete_request.g.dart';

@JsonSerializable(includeIfNull: false)
class AutocompleteRequest {
  @StringConverter()
  final String? input;
  final String key;
  @StringConverter()
  final String? components;
  @StringConverter()
  final String? language;
  @StringConverter()
  final String? locationbias;

  const AutocompleteRequest({
    this.input,
    required this.key,
    this.components,
    this.language,
    this.locationbias,
  });

  factory AutocompleteRequest.fromJson(Map<String, dynamic> json) =>
      _$AutocompleteRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AutocompleteRequestToJson(this);
}
