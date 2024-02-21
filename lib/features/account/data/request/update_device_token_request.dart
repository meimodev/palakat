import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_device_token_request.g.dart';

@JsonSerializable(includeIfNull: false)
class UpdateDeviceTokenRequest {
  final String token;
  final String deviceID;

  const UpdateDeviceTokenRequest({
    required this.token,
    required this.deviceID,
  });

  factory UpdateDeviceTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateDeviceTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateDeviceTokenRequestToJson(this);
}
