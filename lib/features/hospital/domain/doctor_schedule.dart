import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/domain.dart';

part 'doctor_schedule.freezed.dart';
part 'doctor_schedule.g.dart';

@freezed
class DoctorSchedule with _$DoctorSchedule {
  const factory DoctorSchedule({
    required int day,
    @Default([]) List<DoctorScheduleTime> times,
  }) = _DoctorSchedule;

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) =>
      _$DoctorScheduleFromJson(json);
}
