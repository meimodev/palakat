import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/features/domain.dart';

part 'patient.freezed.dart';
part 'patient.g.dart';

@freezed
class Patient with _$Patient {
  const factory Patient({
    @Default("") String serial,
    @Default("") String name,
    @Default("") String mrn,
    @Default("") String firstName,
    @Default("") String lastName,
    DateTime? dateOfBirth,
    @Default("") String email,
    @Default("") String phone,
    @Default(false) bool isPrimaryMrn,
    @Default(PatientStatus.unverified) PatientStatus status,
    @Default("") String approvalStatus,
    String? placeOfBirth,
    IdentityType? identityType,
    String? ktpNumber,
    String? passportNumber,
    String? rtNumber,
    String? rwNumber,
    String? address,
    String? postalCode,
    GeneralData? gender,
    GeneralData? title,
    GeneralData? province,
    GeneralData? city,
    GeneralData? district,
    GeneralData? religion,
    GeneralData? marital,
    GeneralData? education,
    GeneralData? occupation,
    GeneralData? citizenship,
    GeneralData? ethnic,
    GeneralData? village,
    String? photoURL,
    String? identityCardURL,
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);
}
