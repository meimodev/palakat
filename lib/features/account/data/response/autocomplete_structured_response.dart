import 'package:freezed_annotation/freezed_annotation.dart';

part 'autocomplete_structured_response.freezed.dart';
part 'autocomplete_structured_response.g.dart';

@freezed
class AutocompleteStructuredResponse with _$AutocompleteStructuredResponse {
  const factory AutocompleteStructuredResponse({
    @JsonKey(name: 'main_text') @Default("") String mainText,
    @JsonKey(name: 'secondary_text') @Default("") String secondaryText,
  }) = _AutocompleteStructuredResponse;

  factory AutocompleteStructuredResponse.fromJson(Map<String, dynamic> json) =>
      _$AutocompleteStructuredResponseFromJson(json);
}
