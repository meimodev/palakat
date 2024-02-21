import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'appointment_cancel_request.g.dart';

@JsonSerializable(includeIfNull: false)
class AppointmentCancelRequest extends SerialRequest {
  final String? reason;

  const AppointmentCancelRequest({
    required String serial,
    this.reason,
  }) : super(
          serial: serial,
        );

  @override
  factory AppointmentCancelRequest.fromJson(Map<String, dynamic> json) =>
      _$AppointmentCancelRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AppointmentCancelRequestToJson(this);
}
