import 'package:palakat_shared/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/activity.dart';
import '../models/response/response.dart';
import '../models/result.dart';
import '../services/socket_service.dart';

part 'activity_repository.g.dart';

@riverpod
ActivityRepository activityRepository(Ref ref) => ActivityRepository(ref);

class ActivityRepository {
  ActivityRepository(this._ref);

  final Ref _ref;

  Future<Result<PaginationResponseWrapper<Activity>, Failure>> fetchActivities({
    required PaginationRequestWrapper<GetFetchActivitiesRequest>
    paginationRequest,
  }) async {
    try {
      final query = paginationRequest.toJsonFlat((p) => p.toJson());
      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('activity.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Activity.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<Activity, Failure>> fetchActivity({
    required int activityId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('activity.get', {'id': activityId});
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid activity response payload'));
      }
      return Result.success(Activity.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<Activity, Failure>> updateActivity({
    required int activityId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('activity.update', {
        'id': activityId,
        'dto': update,
      });

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update activity response payload'),
        );
      }

      return Result.success(Activity.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<Activity, Failure>> createActivity({
    required CreateActivityRequest request,
  }) async {
    try {
      final payload = request.toJson();

      final locationName = payload.remove('locationName');
      final locationLatitude = payload.remove('locationLatitude');
      final locationLongitude = payload.remove('locationLongitude');

      final hasLocationName =
          locationName is String && locationName.trim().isNotEmpty;
      final hasCoordinates =
          locationLatitude != null && locationLongitude != null;

      if (hasLocationName || hasCoordinates) {
        payload['location'] = {
          'name': hasLocationName ? locationName : '',
          'latitude': locationLatitude,
          'longitude': locationLongitude,
        };
      }

      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('activity.create', payload);

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create activity response payload'),
        );
      }
      return Result.success(Activity.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<void, Failure>> deleteActivity({
    required int activityId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      await socket.rpc('activity.delete', {'id': activityId});
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
