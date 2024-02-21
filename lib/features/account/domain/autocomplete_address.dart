import 'package:freezed_annotation/freezed_annotation.dart';

part 'autocomplete_address.freezed.dart';
part 'autocomplete_address.g.dart';

@freezed
class AutocompleteAddress with _$AutocompleteAddress {
  const factory AutocompleteAddress({
    required String addressLabel,
    required String address,
    required String fullAddress,
  }) = _AutocompleteAddress;

  factory AutocompleteAddress.fromJson(Map<String, dynamic> json) =>
      _$AutocompleteAddressFromJson(json);
}
