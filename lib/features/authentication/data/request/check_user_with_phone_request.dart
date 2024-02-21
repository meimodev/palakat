import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'check_user_with_phone_request.g.dart';

@JsonSerializable(includeIfNull: false)
class CheckUserWithPhoneRequest {
  @StringConverter()
  final String? phone;

  const CheckUserWithPhoneRequest({
    required this.phone,
  });

  factory CheckUserWithPhoneRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckUserWithPhoneRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CheckUserWithPhoneRequestToJson(this);
}
