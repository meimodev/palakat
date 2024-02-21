import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/domain.dart';

part 'social_provider_request.g.dart';

@JsonSerializable(includeIfNull: false)
class SocialProviderRequest {
  final LoginSocialType type;
  final String email;
  final String providerID;

  const SocialProviderRequest({
    required this.type,
    required this.email,
    required this.providerID,
  });

  factory SocialProviderRequest.fromJson(Map<String, dynamic> json) =>
      _$SocialProviderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SocialProviderRequestToJson(this);
}
