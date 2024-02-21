import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/features/data.dart';

part 'profile_response.freezed.dart';
part 'profile_response.g.dart';

@freezed
class ProfileResponse with _$ProfileResponse {
  const factory ProfileResponse({
    @Default("") String serial,
    @Default("") String firstName,
    @Default("") String lastName,
    String? email,
    String? phone,
    IdentityType? identityType,
    String? identityNumber,
    String? ktpNumber,
    String? passportNumber,
    String? placeOfBirth,
    String? dateOfBirth,
    GeneralDataResponse? gender,
    @Default(true) bool emptyPass,
    @Default(true) bool mustVerifiedEmail,
    @Default(true) bool mustChooseArticleTag,
  }) = _ProfileResponse;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);
}
