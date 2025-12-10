import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_payload.freezed.dart';
part 'notification_payload.g.dart';

/// Represents the payload for a notification to be displayed
@freezed
abstract class NotificationPayload with _$NotificationPayload {
  const NotificationPayload._();

  const factory NotificationPayload({
    required String title,
    required String body,
    String? icon,
    Map<String, dynamic>? data,
  }) = _NotificationPayload;

  factory NotificationPayload.fromJson(Map<String, dynamic> json) =>
      _$NotificationPayloadFromJson(json);

  /// Validates that required fields are not empty
  String? validate() {
    if (title.trim().isEmpty) {
      return 'Title is required and cannot be empty';
    }
    if (body.trim().isEmpty) {
      return 'Body is required and cannot be empty';
    }
    return null; // Valid
  }

  /// Creates a validated NotificationPayload, throwing if invalid
  factory NotificationPayload.validated({
    required String title,
    required String body,
    String? icon,
    Map<String, dynamic>? data,
  }) {
    final payload = NotificationPayload(
      title: title,
      body: body,
      icon: icon,
      data: data,
    );

    final error = payload.validate();
    if (error != null) {
      throw ArgumentError(error);
    }

    return payload;
  }
}
