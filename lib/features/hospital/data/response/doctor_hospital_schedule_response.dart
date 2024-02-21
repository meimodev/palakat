import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/data.dart';

part 'doctor_hospital_schedule_response.freezed.dart';
part 'doctor_hospital_schedule_response.g.dart';

@freezed
class DoctorHospitalScheduleResponse with _$DoctorHospitalScheduleResponse {
  const factory DoctorHospitalScheduleResponse({
    @Default('') String serial,
    @Default('') String name,
    @Default([]) List<DoctorScheduleResponse> schedules,
  }) = _DoctorHospitalScheduleResponse;

  factory DoctorHospitalScheduleResponse.fromJson(Map<String, dynamic> json) =>
      _$DoctorHospitalScheduleResponseFromJson(json);
}
