import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'create_user_address_request.g.dart';

@JsonSerializable(includeIfNull: false)
class CreateUserAddressRequest {
  @StringConverter()
  final String? label;
  @StringConverter()
  final String? firstName;
  @StringConverter()
  final String? lastName;
  @StringConverter()
  final String? phone;
  @StringConverter()
  final String? address;
  final double longitude;
  final double latitude;
  final bool isPrimary;
  @StringConverter()
  final String? note;

  const CreateUserAddressRequest({
    required this.label,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isPrimary,
    this.note,
  });

  factory CreateUserAddressRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateUserAddressRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateUserAddressRequestToJson(this);
}
