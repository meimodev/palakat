import 'package:palakat_shared/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/response/response.dart';
import '../models/result.dart';
import '../models/revenue.dart';
import '../services/socket_service.dart';

part 'revenue_repository.g.dart';

/// Riverpod provider for RevenueRepository
@riverpod
RevenueRepository revenueRepository(Ref ref) => RevenueRepository(ref);

/// Abstract interface for revenue data operations
abstract class RevenueRepositoryBase {
  /// Creates a new revenue record
  Future<Result<Revenue, Failure>> createRevenue({
    required CreateRevenueRequest request,
  });

  /// Fetches paginated list of revenues
  Future<Result<PaginationResponseWrapper<Revenue>, Failure>> fetchRevenues({
    required PaginationRequestWrapper paginationRequest,
  });

  /// Fetches a single revenue by ID
  Future<Result<Revenue, Failure>> fetchRevenue({required int revenueId});

  /// Updates an existing revenue record
  Future<Result<Revenue, Failure>> updateRevenue({
    required int revenueId,
    required Map<String, dynamic> update,
  });

  /// Deletes a revenue record
  Future<Result<void, Failure>> deleteRevenue({required int revenueId});
}

/// Implementation of RevenueRepository for API operations
class RevenueRepository implements RevenueRepositoryBase {
  RevenueRepository(this._ref);

  final Ref _ref;

  @override
  Future<Result<PaginationResponseWrapper<Revenue>, Failure>> fetchRevenues({
    required PaginationRequestWrapper paginationRequest,
  }) async {
    try {
      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('revenue.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Revenue.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<Revenue, Failure>> fetchRevenue({
    required int revenueId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('revenue.get', {'id': revenueId});
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid revenue response payload'));
      }
      return Result.success(Revenue.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<Revenue, Failure>> updateRevenue({
    required int revenueId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);

      final body = await socket.rpc('revenue.update', {
        'id': revenueId,
        'dto': update,
      });

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update revenue response payload'),
        );
      }

      return Result.success(Revenue.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<Revenue, Failure>> createRevenue({
    required CreateRevenueRequest request,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('revenue.create', request.toJson());
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create revenue response payload'),
        );
      }
      return Result.success(Revenue.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<void, Failure>> deleteRevenue({required int revenueId}) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      await socket.rpc('revenue.delete', {'id': revenueId});
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
