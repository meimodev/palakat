import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/features/notification/data/response/notification_data_response.dart';

part 'notification_response.freezed.dart';
part 'notification_response.g.dart';

@freezed
class NotificationResponse with _$NotificationResponse {
  const factory NotificationResponse({
    @Default("") String serial,
    @Default("") String userSerial,
    @Default("") String title,
    @Default("") String body,
    @Default("") String imageURL,
    NotificationDataResponse? data,
    DateTime? readAt,
    DateTime? createdAt,
  }) = _NotificationResponse;

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);
}
