import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// Notification type enum matching backend NotificationType
enum NotificationType {
  @JsonValue('ACTIVITY_CREATED')
  activityCreated,
  @JsonValue('APPROVAL_REQUIRED')
  approvalRequired,
  @JsonValue('APPROVAL_CONFIRMED')
  approvalConfirmed,
  @JsonValue('APPROVAL_REJECTED')
  approvalRejected,
}

/// Notification model representing push notifications in the system
@freezed
abstract class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required int id,
    required String title,
    required String body,
    required NotificationType type,
    required String recipient,
    int? activityId,
    required bool isRead,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}
