import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/features/domain.dart';

part 'user_data.g.dart';

@JsonSerializable(includeIfNull: false)
class UserData {
  final String serial;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final IdentityType? identityType;
  final String? identityNumber;
  final String? ktpNumber;
  final String? passportNumber;
  final String? placeOfBirth;
  final String? dateOfBirth;
  final GeneralData? gender;
  final bool mustVerifiedEmail;
  final bool emptyPass;

  const UserData({
    required this.serial,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.identityType,
    this.identityNumber,
    this.ktpNumber,
    this.passportNumber,
    this.placeOfBirth,
    this.dateOfBirth,
    this.gender,
    required this.mustVerifiedEmail,
    required this.emptyPass,
  });

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
