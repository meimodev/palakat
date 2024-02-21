import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/domain.dart';

part 'doctor_hospital_schedule.freezed.dart';
part 'doctor_hospital_schedule.g.dart';

@freezed
class DoctorHospitalSchedule with _$DoctorHospitalSchedule {
  const factory DoctorHospitalSchedule({
    required String serial,
    required String name,
    @Default([]) List<DoctorSchedule> schedules,
  }) = _DoctorHospitalSchedule;

  factory DoctorHospitalSchedule.fromJson(Map<String, dynamic> json) =>
      _$DoctorHospitalScheduleFromJson(json);
}
