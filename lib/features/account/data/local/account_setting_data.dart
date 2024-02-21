import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_setting_data.freezed.dart';
part 'account_setting_data.g.dart';

@freezed
class AccountSettingData with _$AccountSettingData {
  const factory AccountSettingData({
    bool? enableBiometric,
    bool? authenticatedPatientPortal,
    String? language,
  }) = _AccountSettingData;

  factory AccountSettingData.fromJson(Map<String, dynamic> json) =>
      _$AccountSettingDataFromJson(json);
}
