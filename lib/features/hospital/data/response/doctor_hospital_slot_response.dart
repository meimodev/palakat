import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_hospital_slot_response.freezed.dart';
part 'doctor_hospital_slot_response.g.dart';

@freezed
class DoctorHospitalSlotResponse with _$DoctorHospitalSlotResponse {
  const factory DoctorHospitalSlotResponse({
    @Default([]) List<String> times,
  }) = _DoctorHospitalSlotResponse;

  factory DoctorHospitalSlotResponse.fromJson(Map<String, dynamic> json) =>
      _$DoctorHospitalSlotResponseFromJson(json);
}
