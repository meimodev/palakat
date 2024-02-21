import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'check_user_with_email_request.g.dart';

@JsonSerializable(includeIfNull: false)
class CheckUserWithEmailRequest {
  @StringConverter()
  final String? email;

  const CheckUserWithEmailRequest({
    required this.email,
  });

  factory CheckUserWithEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$CheckUserWithEmailRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CheckUserWithEmailRequestToJson(this);
}
