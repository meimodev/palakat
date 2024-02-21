import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/features/data.dart';

class NotificationRepository {
  final NotificationApi _notificationApi;

  NotificationRepository(
    this._notificationApi,
  );

  Future<Result<PaginationResponse<NotificationResponse>>> notifications(
      NotificationListRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(PaginationResponse.fromJson({
    //     "data": List.generate(
    //       20,
    //       (index) => {
    //         "serial": index.toString(),
    //         "userSerial": "string",
    //         "title": "string",
    //         "body": "string",
    //         "imageURL": "string",
    //         "data": {"contextType": "appointment", "context": {}},
    //         "readAt": index % 2 == 0 ? "2024-01-11T07:57:48.262Z" : null,
    //         "createdAt": "2024-01-11T07:57:48.262Z"
    //       },
    //     ).toList(),
    //     "total": 100,
    //     "currentPage": 1,
    //     "totalPage": 5
    //   }, (p0) => NotificationResponse.fromJson(p0 as Map<String, dynamic>))),
    // );

    return _notificationApi.notifications(request);
  }

  Future<Result<SuccessResponse>> read(SerialRequest request) {
    return _notificationApi.read(request);
  }

  Future<Result<SuccessResponse>> readAll() {
    return _notificationApi.readAll();
  }
}

final notificationRepositoryProvider =
    Provider.autoDispose<NotificationRepository>((ref) {
  return NotificationRepository(
    ref.read(notificationApiProvider),
  );
});
