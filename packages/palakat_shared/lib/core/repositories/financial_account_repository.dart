import 'package:dio/dio.dart';
import 'package:palakat_shared/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/endpoint.dart';
import '../models/financial_account_number.dart';
import '../models/response/response.dart';
import '../models/result.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';

part 'financial_account_repository.g.dart';

/// Riverpod provider for FinancialAccountRepository
@riverpod
FinancialAccountRepository financialAccountRepository(Ref ref) =>
    FinancialAccountRepository(ref);

/// Implementation of FinancialAccountRepository for API operations
class FinancialAccountRepository {
  FinancialAccountRepository(this._ref);

  final Ref _ref;

  /// Fetches list of financial account numbers with pagination
  Future<Result<PaginationResponseWrapper<FinancialAccountNumber>, Failure>>
      getAll({
    required PaginationRequestWrapper<GetFinancialAccountsRequest>
        paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.financialAccountNumbers,
        queryParameters: query,
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => FinancialAccountNumber.fromJson(e as Map<String, dynamic>),
      );

      return Result.success(result);
    } on DioException catch (e) {
      final error =
          ErrorMapper.fromDio(e, 'Failed to fetch financial accounts');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error =
          ErrorMapper.unknown('Failed to fetch financial accounts', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }


  /// Creates a new financial account number
  Future<Result<FinancialAccountNumber, Failure>> create({
    required Map<String, dynamic> data,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.financialAccountNumbers,
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create financial account response payload'),
        );
      }
      return Result.success(FinancialAccountNumber.fromJson(json));
    } on DioException catch (e) {
      final error =
          ErrorMapper.fromDio(e, 'Failed to create financial account');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error =
          ErrorMapper.unknown('Failed to create financial account', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  /// Updates an existing financial account number
  Future<Result<FinancialAccountNumber, Failure>> update({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.financialAccountNumber(id.toString()),
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update financial account response payload'),
        );
      }
      return Result.success(FinancialAccountNumber.fromJson(json));
    } on DioException catch (e) {
      final error =
          ErrorMapper.fromDio(e, 'Failed to update financial account');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error =
          ErrorMapper.unknown('Failed to update financial account', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  /// Deletes a financial account number
  Future<Result<void, Failure>> delete({required int id}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.financialAccountNumber(id.toString()));
      return Result.success(null);
    } on DioException catch (e) {
      final error =
          ErrorMapper.fromDio(e, 'Failed to delete financial account');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error =
          ErrorMapper.unknown('Failed to delete financial account', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }
}
