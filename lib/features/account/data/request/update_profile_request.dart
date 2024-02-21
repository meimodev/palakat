import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'update_profile_request.g.dart';

@JsonSerializable(includeIfNull: false)
class UpdateProfileRequest {
  @StringConverter()
  final String firstName;
  @StringConverter()
  final String lastName;
  @StringConverter()
  final String? email;
  @StringConverter()
  final String? phone;
  final IdentityType? identityType;
  @StringConverter()
  final String? identityNumber;
  @StringConverter()
  final String? placeOfBirth;
  final DateTime? dateOfBirth;
  final String? genderSerial;
  final String? otp;

  const UpdateProfileRequest({
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.identityType,
    this.identityNumber,
    this.placeOfBirth,
    this.dateOfBirth,
    this.genderSerial,
    this.otp,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}
