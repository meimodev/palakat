import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'appointment_manage_request.g.dart';

@JsonSerializable(includeIfNull: false)
class AppointmentManageRequest extends SerialRequest {
  final String type;

  const AppointmentManageRequest({
    required String serial,
    required this.type,
  }) : super(
          serial: serial,
        );

  @override
  factory AppointmentManageRequest.fromJson(Map<String, dynamic> json) =>
      _$AppointmentManageRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AppointmentManageRequestToJson(this);
}
