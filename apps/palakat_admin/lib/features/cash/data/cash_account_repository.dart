import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/services.dart';
import 'package:palakat_admin/utils.dart';
import 'package:palakat_shared/core/config/endpoint.dart';

import '../domain/cash_account.dart';

final cashAccountRepositoryProvider = Provider<CashAccountRepository>((ref) {
  return CashAccountRepository(ref);
});

class CashAccountRepository {
  CashAccountRepository(this._ref);

  final Ref _ref;

  Future<Result<PaginationResponseWrapper<CashAccount>, Failure>>
  fetchAccounts({
    required int page,
    required int pageSize,
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
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.cashAccounts,
        queryParameters: query,
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => CashAccount.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch cash accounts');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch cash accounts', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<CashAccount, Failure>> create({
    required String name,
    String? currency,
    int? openingBalance,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.cashAccounts,
        data: {
          'name': name,
          if (currency != null && currency.isNotEmpty) 'currency': currency,
          if (openingBalance != null) 'openingBalance': openingBalance,
        },
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create cash account response payload'),
        );
      }

      return Result.success(CashAccount.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to create cash account');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to create cash account', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<CashAccount, Failure>> update({
    required int id,
    String? name,
    String? currency,
    int? openingBalance,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.cashAccount(id.toString()),
        data: {
          if (name != null) 'name': name,
          if (currency != null) 'currency': currency,
          if (openingBalance != null) 'openingBalance': openingBalance,
        },
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update cash account response payload'),
        );
      }

      return Result.success(CashAccount.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to update cash account');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to update cash account', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<void, Failure>> delete({required int id}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.cashAccount(id.toString()));
      return Result.success(null);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to delete cash account');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to delete cash account', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }
}
