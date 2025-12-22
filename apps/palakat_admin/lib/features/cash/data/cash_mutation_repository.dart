import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/services.dart';
import 'package:palakat_admin/utils.dart';
import 'package:palakat_shared/core/config/endpoint.dart';

import '../domain/cash_mutation.dart';

final cashMutationRepositoryProvider = Provider<CashMutationRepository>((ref) {
  return CashMutationRepository(ref);
});

class CashMutationRepository {
  CashMutationRepository(this._ref);

  final Ref _ref;

  Future<Result<PaginationResponseWrapper<CashMutation>, Failure>>
  fetchMutations({
    required int page,
    required int pageSize,
    int? accountId,
    CashMutationType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final query = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
        if (accountId != null) 'accountId': accountId,
        if (type != null) 'type': type.apiValue,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.cashMutations,
        queryParameters: query,
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => CashMutation.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch cash mutations');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown(
        'Failed to fetch cash mutations',
        e,
        st,
      );
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<CashMutation, Failure>> fetchMutation({
    required int mutationId,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.cashMutation(mutationId.toString()),
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid cash mutation response payload'),
        );
      }

      return Result.success(CashMutation.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch cash mutation');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch cash mutation', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<CashMutation, Failure>> create({
    required CashMutationType type,
    required int amount,
    int? fromAccountId,
    int? toAccountId,
    required DateTime happenedAt,
    String? note,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.cashMutations,
        data: {
          'type': type.apiValue,
          'amount': amount,
          if (fromAccountId != null) 'fromAccountId': fromAccountId,
          if (toAccountId != null) 'toAccountId': toAccountId,
          'happenedAt': happenedAt.toIso8601String(),
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create cash mutation response payload'),
        );
      }

      return Result.success(CashMutation.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to create cash mutation');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown(
        'Failed to create cash mutation',
        e,
        st,
      );
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<CashMutation, Failure>> transfer({
    required int fromAccountId,
    required int toAccountId,
    required int amount,
    required DateTime happenedAt,
    String? note,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.cashTransfer,
        data: {
          'fromAccountId': fromAccountId,
          'toAccountId': toAccountId,
          'amount': amount,
          'happenedAt': happenedAt.toIso8601String(),
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid transfer cash response payload'),
        );
      }

      return Result.success(CashMutation.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to transfer cash');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to transfer cash', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<void, Failure>> delete({required int id}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.cashMutation(id.toString()));
      return Result.success(null);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to delete cash mutation');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown(
        'Failed to delete cash mutation',
        e,
        st,
      );
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }
}
