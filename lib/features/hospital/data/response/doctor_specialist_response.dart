import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_specialist_response.freezed.dart';
part 'doctor_specialist_response.g.dart';

@freezed
class DoctorSpecialistResponse with _$DoctorSpecialistResponse {
  const factory DoctorSpecialistResponse({
    @Default("") String doctorSerial,
    @Default("") String hospitalSerial,
    @Default("") String specialistSerial,
  }) = _DoctorSpecialistResponse;

  factory DoctorSpecialistResponse.fromJson(Map<String, dynamic> json) =>
      _$DoctorSpecialistResponseFromJson(json);
}
