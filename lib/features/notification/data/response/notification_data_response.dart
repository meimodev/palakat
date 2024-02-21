import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_data_response.freezed.dart';
part 'notification_data_response.g.dart';

@freezed
class NotificationDataResponse with _$NotificationDataResponse {
  const factory NotificationDataResponse({
    @Default("") String contextType,
    @Default({}) dynamic context,
  }) = _NotificationDataResponse;

  factory NotificationDataResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationDataResponseFromJson(json);
}
