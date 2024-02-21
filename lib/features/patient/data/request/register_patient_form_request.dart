import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'register_patient_form_request.g.dart';

@JsonSerializable(includeIfNull: false)
class RegisterPatientFormRequest {
  final int? step;
  @StringConverter()
  final String? firstName;
  @StringConverter()
  final String? lastName;
  final DateTime? dateOfBirth;
  @StringConverter()
  final String? phone;
  @StringConverter()
  final String? email;
  final String? titleSerial;
  @StringConverter()
  final String? placeOfBirth;
  final IdentityType? identityType;
  @StringConverter()
  final String? identityNumber;
  final String? genderSerial;
  @StringConverter()
  final String? address;
  @StringConverter()
  final String? rtNumber;
  @StringConverter()
  final String? rwNumber;
  final String? provinceSerial;
  final String? citySerial;
  final String? districtSerial;
  final String? villageSerial;
  @StringConverter()
  final String? postalCode;
  final String? religionSerial;
  final String? maritalSerial;
  final String? occupationSerial;
  final String? citizenshipSerial;
  final String? ethnicSerial;
  final String? educationSerial;
  final String? identityCardSerial;
  final String? photoSerial;
  final String? otp;
  final bool? isVisitFrontOffice;

  const RegisterPatientFormRequest({
    this.step,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.phone,
    this.email,
    this.titleSerial,
    this.placeOfBirth,
    this.identityType,
    this.identityNumber,
    this.genderSerial,
    this.address,
    this.rtNumber,
    this.rwNumber,
    this.provinceSerial,
    this.citySerial,
    this.districtSerial,
    this.villageSerial,
    this.postalCode,
    this.religionSerial,
    this.maritalSerial,
    this.educationSerial,
    this.occupationSerial,
    this.citizenshipSerial,
    this.ethnicSerial,
    this.identityCardSerial,
    this.photoSerial,
    this.otp,
    this.isVisitFrontOffice,
  });

  factory RegisterPatientFormRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterPatientFormRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterPatientFormRequestToJson(this);
}
