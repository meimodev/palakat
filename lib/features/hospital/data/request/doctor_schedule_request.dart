import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_schedule_request.g.dart';

@JsonSerializable(includeIfNull: false)
class DoctorScheduleRequest {
  final String doctorSerial;
  final String hospitalSerial;

  const DoctorScheduleRequest({
    required this.doctorSerial,
    required this.hospitalSerial,
  });

  factory DoctorScheduleRequest.fromJson(Map<String, dynamic> json) =>
      _$DoctorScheduleRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DoctorScheduleRequestToJson(this);
}
