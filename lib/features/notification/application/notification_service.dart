import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';

class NotificationService {
  final NotificationRepository _notificationRepository;

  NotificationService(
    this._notificationRepository,
  );

  Future<Result<PaginationResponse<Notification>>> getNotifications(
      NotificationListRequest request) async {
    final result = await _notificationRepository.notifications(request);

    return result.when(
      success: (response) => Result.success(
        PaginationResponse.fromJson(
          response.toJson((p0) => p0.toJson()),
          (eachData) => Notification.fromJson(
            eachData as Map<String, dynamic>,
          ),
        ),
      ),
      failure: (e, st) => Result.failure(e, st),
    );
  }

  Future<Result<SuccessResponse>> read(String serial) async {
    return await _notificationRepository.read(
      SerialRequest(serial: serial),
    );
  }

  Future<Result<SuccessResponse>> readAll() async {
    return await _notificationRepository.readAll();
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final notification = ref.read(notificationRepositoryProvider);
  return NotificationService(notification);
});
