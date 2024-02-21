import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/data.dart';

part 'autocomplete_response.freezed.dart';
part 'autocomplete_response.g.dart';

@freezed
class AutocompleteResponse with _$AutocompleteResponse {
  const factory AutocompleteResponse({
    @JsonKey(name: 'description')
    @Default("")
        String description,
    @JsonKey(name: 'structured_formatting')
        AutocompleteStructuredResponse? formatted,
  }) = _AutocompleteResponse;

  factory AutocompleteResponse.fromJson(Map<String, dynamic> json) =>
      _$AutocompleteResponseFromJson(json);
}
