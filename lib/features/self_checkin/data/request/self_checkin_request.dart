import 'package:freezed_annotation/freezed_annotation.dart';

part 'self_checkin_request.g.dart';

@JsonSerializable(includeIfNull: false)
class SelfCheckinRequest {
  final String appointmentSerial;

  const SelfCheckinRequest({
    required this.appointmentSerial,
  });

  @override
  factory SelfCheckinRequest.fromJson(Map<String, dynamic> json) =>
      _$SelfCheckinRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SelfCheckinRequestToJson(this);
}
