import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/models/models.dart';

part 'settings_state.freezed.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    Account? account,
    Membership? membership,
    @Default('') String appVersion,
    @Default('') String buildNumber,
    @Default(false) bool isSigningOut,
    String? errorMessage,
  }) = _SettingsState;
}
