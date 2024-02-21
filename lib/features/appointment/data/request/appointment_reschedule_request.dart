import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'appointment_reschedule_request.g.dart';

@JsonSerializable(includeIfNull: false)
class AppointmentRescheduleRequest extends SerialRequest {
  final DateTime dateTime;

  const AppointmentRescheduleRequest({
    required String serial,
    required this.dateTime,
  }) : super(
          serial: serial,
        );

  @override
  factory AppointmentRescheduleRequest.fromJson(Map<String, dynamic> json) =>
      _$AppointmentRescheduleRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AppointmentRescheduleRequestToJson(this);
}
