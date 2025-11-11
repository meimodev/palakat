import 'package:dio/dio.dart';
import 'package:palakat_admin/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/revenue.dart';
import '../models/result.dart';
import '../models/response/response.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';
import '../config/endpoint.dart';

part 'revenue_repository.g.dart';

@riverpod
RevenueRepository revenueRepository(Ref ref) => RevenueRepository(ref);

class RevenueRepository {
  RevenueRepository(this._ref);

  final Ref _ref;

  Future<Result<PaginationResponseWrapper<Revenue>, Failure>> fetchRevenues({
    required PaginationRequestWrapper paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.revenues,
        queryParameters: query,
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Revenue.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch revenue');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch revenue', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Revenue, Failure>> fetchRevenue({required int revenueId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.revenue(revenueId.toString()),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid revenue response payload'));
      }
      return Result.success(Revenue.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch revenue');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch revenue', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Revenue, Failure>> updateRevenue({
    required int revenueId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.revenue(revenueId.toString()),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid update revenue response payload'));
      }

      return Result.success(Revenue.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to update revenue');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to update revenue', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Revenue, Failure>> createRevenue({required Map<String, dynamic> data}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.revenues,
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid create revenue response payload'));
      }
      return Result.success(Revenue.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to create revenue');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to create revenue', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<void, Failure>> deleteRevenue({required int revenueId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.revenue(revenueId.toString()));
      return Result.success(null);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to delete revenue');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to delete revenue', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

}
