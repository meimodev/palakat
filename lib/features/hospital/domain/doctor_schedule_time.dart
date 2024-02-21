import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_schedule_time.freezed.dart';
part 'doctor_schedule_time.g.dart';

@freezed
class DoctorScheduleTime with _$DoctorScheduleTime {
  const factory DoctorScheduleTime({
    required String timeFrom,
    required String timeTo,
  }) = _DoctorScheduleTime;

  factory DoctorScheduleTime.fromJson(Map<String, dynamic> json) =>
      _$DoctorScheduleTimeFromJson(json);
}
