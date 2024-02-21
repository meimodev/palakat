import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'register_patient_mrn_request.g.dart';

@JsonSerializable(includeIfNull: false)
class RegisterPatientMRNRequest {
  final String mrn;
  final DateTime? dateOfBirth;
  final bool? isVisitFrontOffice;
  @StringConverter()
  final String? phone;
  final String? otp;

  const RegisterPatientMRNRequest(
      {required this.mrn,
      required this.dateOfBirth,
      this.isVisitFrontOffice,
      this.phone,
      this.otp});

  factory RegisterPatientMRNRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterPatientMRNRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterPatientMRNRequestToJson(this);
}
