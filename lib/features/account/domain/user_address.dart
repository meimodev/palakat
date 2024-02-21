import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_address.freezed.dart';
part 'user_address.g.dart';

@freezed
class UserAddress with _$UserAddress {
  const factory UserAddress({
    @Default("") String serial,
    String? userSerial,
    @Default("") String label,
    @Default("") String name,
    String? firstName,
    String? lastName,
    @Default("") String phone,
    String? address,
    String? note,
    double? longitude,
    double? latitude,
    @Default(false) bool isPrimary,
  }) = _UserAddress;

  factory UserAddress.fromJson(Map<String, dynamic> json) =>
      _$UserAddressFromJson(json);
}
