import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_settings.freezed.dart';

part 'notification_settings.g.dart';

/// Model representing user notification preferences
@freezed
abstract class NotificationSettingsModel with _$NotificationSettingsModel {
  const factory NotificationSettingsModel({
    @Default(true) bool activityUpdatesEnabled,
    @Default(true) bool approvalRequestsEnabled,
    @Default(true) bool generalAnnouncementsEnabled,
    @Default(true) bool soundEnabled,
    @Default(true) bool vibrationEnabled,
  }) = _NotificationSettingsModel;

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsModelFromJson(json);
}
