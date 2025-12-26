import 'package:palakat_shared/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/financial_account_number.dart';
import '../models/response/response.dart';
import '../models/result.dart';
import '../services/socket_service.dart';

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
      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('financialAccountNumber.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => FinancialAccountNumber.fromJson(e as Map<String, dynamic>),
      );

      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Creates a new financial account number
  Future<Result<FinancialAccountNumber, Failure>> create({
    required Map<String, dynamic> data,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('financialAccountNumber.create', data);
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create financial account response payload'),
        );
      }
      return Result.success(FinancialAccountNumber.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Updates an existing financial account number
  Future<Result<FinancialAccountNumber, Failure>> update({
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('financialAccountNumber.update', {
        'id': id,
        'dto': data,
      });
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update financial account response payload'),
        );
      }
      return Result.success(FinancialAccountNumber.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Deletes a financial account number
  Future<Result<void, Failure>> delete({required int id}) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      await socket.rpc('financialAccountNumber.delete', {'id': id});
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
