import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'check_phone_request.g.dart';

@JsonSerializable(includeIfNull: false)
class CheckPhoneRequest {
  @StringConverter()
  final String? phone;

  const CheckPhoneRequest({
    required this.phone,
  });

  factory CheckPhoneRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckPhoneRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CheckPhoneRequestToJson(this);
}
