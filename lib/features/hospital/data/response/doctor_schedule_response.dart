import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_schedule_response.freezed.dart';
part 'doctor_schedule_response.g.dart';

@freezed
class DoctorScheduleResponse with _$DoctorScheduleResponse {
  const factory DoctorScheduleResponse({
    @Default('') String doctorSerial,
    @Default('') String hospitalSerial,
    @Default(1) int day,
    String? timeFrom,
    String? timeTo,
  }) = _DoctorScheduleResponse;

  factory DoctorScheduleResponse.fromJson(Map<String, dynamic> json) =>
      _$DoctorScheduleResponseFromJson(json);
}
