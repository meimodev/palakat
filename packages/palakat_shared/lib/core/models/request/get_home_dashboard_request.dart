import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_home_dashboard_request.freezed.dart';
part 'get_home_dashboard_request.g.dart';

@Freezed(toJson: true, fromJson: true)
abstract class GetHomeDashboardRequest with _$GetHomeDashboardRequest {
  const factory GetHomeDashboardRequest() = _GetHomeDashboardRequest;

  factory GetHomeDashboardRequest.fromJson(Map<String, dynamic> json) =>
      _$GetHomeDashboardRequestFromJson(json);
}
