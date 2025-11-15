import 'package:dio/dio.dart';
import 'package:palakat_admin/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/activity.dart';
import '../models/result.dart';
import '../models/response/response.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';
import '../config/endpoint.dart';

part 'activity_repository.g.dart';

@riverpod
ActivityRepository activityRepository(Ref ref) => ActivityRepository(ref);

class ActivityRepository {
  ActivityRepository(this._ref);

  final Ref _ref;

  Future<Result<PaginationResponseWrapper<Activity>, Failure>> fetchActivities({
    required PaginationRequestWrapper<GetFetchActivitiesRequest> paginationRequest,
  }) async {
    try {

      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.activities,
        queryParameters: query,
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Activity.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch activities');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch activities', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Activity, Failure>> fetchActivity({required int activityId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.activity(activityId.toString()),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid activity response payload'));
      }
      return Result.success(Activity.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch activity');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch activity', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Activity, Failure>> updateActivity({
    required int activityId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.activity(activityId.toString()),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid update activity response payload'));
      }

      return Result.success(Activity.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to update activity');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to update activity', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Activity, Failure>> createActivity({required Map<String, dynamic> data}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.activities,
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid create activity response payload'));
      }
      return Result.success(Activity.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to create activity');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to create activity', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<void, Failure>> deleteActivity({required int activityId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.activity(activityId.toString()));
      return Result.success(null);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to delete activity');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to delete activity', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

}
