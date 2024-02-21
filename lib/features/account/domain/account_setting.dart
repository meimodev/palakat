import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_setting.freezed.dart';
part 'account_setting.g.dart';

@freezed
class AccountSetting with _$AccountSetting {
  const factory AccountSetting({
    required bool enableBiometric,
    required bool authenticatedPatientPortal,
    required String language,
  }) = _AccountSetting;

  factory AccountSetting.fromJson(Map<String, dynamic> json) =>
      _$AccountSettingFromJson(json);
}
