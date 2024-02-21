import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/domain.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
class Notification with _$Notification {
  const factory Notification({
    @Default("") String serial,
    @Default("") String userSerial,
    @Default("") String title,
    @Default("") String body,
    @Default("") String imageURL,
    NotificationData? data,
    DateTime? readAt,
    DateTime? createdAt,
  }) = _Notification;

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
}
