import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/domain.dart';

part 'social_provider_check_email_request.g.dart';

@JsonSerializable(includeIfNull: false)
class SocialProviderCheckEmailRequest {
  final LoginSocialType type;
  final String providerID;

  const SocialProviderCheckEmailRequest({
    required this.type,
    required this.providerID,
  });

  factory SocialProviderCheckEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$SocialProviderCheckEmailRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SocialProviderCheckEmailRequestToJson(this);
}
