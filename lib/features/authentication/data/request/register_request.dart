import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'register_request.g.dart';

@JsonSerializable(includeIfNull: false)
class RegisterRequest {
  final String type;
  @StringConverter()
  final String? firstName;
  @StringConverter()
  final String? lastName;
  @StringConverter()
  final String? placeOfBirth;
  final DateTime? dateOfBirth;
  @StringConverter()
  final String? genderSerial;
  @StringConverter()
  final String? phone;
  @StringConverter()
  final String? email;
  @StringConverter()
  final String? password;
  final String? otp;

  const RegisterRequest({
    required this.type,
    this.firstName,
    this.lastName,
    this.placeOfBirth,
    this.dateOfBirth,
    this.genderSerial,
    this.phone,
    this.email,
    this.password,
    this.otp,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
