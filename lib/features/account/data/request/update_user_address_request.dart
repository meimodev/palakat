import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import './create_user_address_request.dart';

part 'update_user_address_request.g.dart';

@JsonSerializable(includeIfNull: false)
class UpdateUserAddressRequest extends CreateUserAddressRequest {
  final String serial;

  const UpdateUserAddressRequest({
    required String label,
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required bool isPrimary,
    required this.serial,
    String? note,
  }) : super(
          label: label,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          address: address,
          latitude: latitude,
          longitude: longitude,
          isPrimary: isPrimary,
          note: note,
        );

  factory UpdateUserAddressRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserAddressRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UpdateUserAddressRequestToJson(this);
}
