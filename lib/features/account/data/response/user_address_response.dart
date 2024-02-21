import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_address_response.freezed.dart';
part 'user_address_response.g.dart';

@freezed
class UserAddressResponse with _$UserAddressResponse {
  const factory UserAddressResponse({
    @JsonKey(name: 'serial') @Default("") String serial,
    @JsonKey(name: 'userSerial') String? userSerial,
    @JsonKey(name: 'label') @Default("") String label,
    @JsonKey(name: 'name') @Default("") String name,
    @JsonKey(name: 'firstName') String? firstName,
    @JsonKey(name: 'lastName') String? lastName,
    @JsonKey(name: 'phone') @Default("") String phone,
    @JsonKey(name: 'address') String? address,
    @JsonKey(name: 'note') String? note,
    @JsonKey(name: 'longitude') double? longitude,
    @JsonKey(name: 'latitude') double? latitude,
    @JsonKey(name: 'isPrimary') @Default(false) bool isPrimary,
  }) = _UserAddressResponse;

  factory UserAddressResponse.fromJson(Map<String, dynamic> json) =>
      _$UserAddressResponseFromJson(json);
}
