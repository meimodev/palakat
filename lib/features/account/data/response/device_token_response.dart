import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_token_response.freezed.dart';
part 'device_token_response.g.dart';

@freezed

class DeviceTokenResponse with _$DeviceTokenResponse {
  const factory DeviceTokenResponse({
    @Default("") String userSerial,
    @Default("") String deviceID,
    @Default("") String token,
  }) = _DeviceTokenResponse;

  factory DeviceTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenResponseFromJson(json);
}
