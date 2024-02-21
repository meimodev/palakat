import 'package:freezed_annotation/freezed_annotation.dart';

part 'delete_device_token_request.g.dart';

@JsonSerializable(includeIfNull: false)
class DeleteDeviceTokenRequest {
  final String userSerial;
  final String deviceID;

  const DeleteDeviceTokenRequest({
    required this.userSerial,
    required this.deviceID,
  });

  factory DeleteDeviceTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$DeleteDeviceTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteDeviceTokenRequestToJson(this);
}
