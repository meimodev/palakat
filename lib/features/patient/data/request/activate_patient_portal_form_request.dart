import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'activate_patient_portal_form_request.g.dart';

@JsonSerializable(includeIfNull: false)
class ActivatePatientPortalFormRequest {
  final String? firstName;
  final String? lastName;
  @StringConverter()
  final DateTime? dateOfBirth;
  final String? phone;
  final String? email;
  @StringConverter()
  final IdentityType? identityType;
  final String? identityNumber;
  final String? identityCardSerial;
  final String? photoSerial;
  final String? otp;
  final String? pin;

  const ActivatePatientPortalFormRequest({
    this.firstName,
    this.lastName,
    this.email,
    this.dateOfBirth,
    this.phone,
    this.identityType,
    this.identityNumber,
    this.identityCardSerial,
    this.photoSerial,
    this.otp,
    this.pin,
  });

  factory ActivatePatientPortalFormRequest.fromJson(
          Map<String, dynamic> json) =>
      _$ActivatePatientPortalFormRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ActivatePatientPortalFormRequestToJson(this);
}
