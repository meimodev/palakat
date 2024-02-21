import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';

part 'notification_list_request.g.dart';

@JsonSerializable(includeIfNull: false)
class NotificationListRequest extends PaginationRequest {
  final bool? isRead;

  const NotificationListRequest({
    required int page,
    required int pageSize,
    String? sortType,
    String? sortBy,
    String? search,
    this.isRead,
  }) : super(
          page: page,
          pageSize: pageSize,
          sortType: sortType,
          sortBy: sortBy,
          search: search,
        );

  @override
  factory NotificationListRequest.fromJson(Map<String, dynamic> json) =>
      _$NotificationListRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NotificationListRequestToJson(this);
}
