import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/data.dart';

part 'patient_response.freezed.dart';
part 'patient_response.g.dart';

@freezed
class PatientResponse with _$PatientResponse {
  const factory PatientResponse({
    @Default("") String serial,
    @Default("") String name,
    @Default("") String mrn,
    @Default("") String firstName,
    @Default("") String lastName,
    DateTime? dateOfBirth,
    @Default("") String email,
    @Default("") String phone,
    @Default(false) bool isPrimaryMrn,
    @Default("") String status,
    @Default("") String approvalStatus,
    String? placeOfBirth,
    String? ktpNumber,
    String? passportNumber,
    String? rtNumber,
    String? rwNumber,
    String? address,
    String? postalCode,
    GeneralDataResponse? gender,
    GeneralDataResponse? title,
    GeneralDataResponse? province,
    GeneralDataResponse? city,
    GeneralDataResponse? district,
    GeneralDataResponse? religion,
    GeneralDataResponse? marital,
    GeneralDataResponse? education,
    GeneralDataResponse? occupation,
    GeneralDataResponse? citizenship,
    GeneralDataResponse? ethnic,
    GeneralDataResponse? village,
    String? photoURL,
    String? identityCardURL,
    String? identityType,
  }) = _PatientResponse;

  factory PatientResponse.fromJson(Map<String, dynamic> json) =>
      _$PatientResponseFromJson(json);
}
