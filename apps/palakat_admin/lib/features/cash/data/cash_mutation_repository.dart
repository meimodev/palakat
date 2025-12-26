import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/services.dart';

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

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('cashMutation.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => CashMutation.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<CashMutation, Failure>> fetchMutation({
    required int mutationId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('cashMutation.get', {'id': mutationId});

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid cash mutation response payload'),
        );
      }

      return Result.success(CashMutation.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
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
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('cashMutation.create', {
        'type': type.apiValue,
        'amount': amount,
        if (fromAccountId != null) 'fromAccountId': fromAccountId,
        if (toAccountId != null) 'toAccountId': toAccountId,
        'happenedAt': happenedAt.toIso8601String(),
        if (note != null && note.isNotEmpty) 'note': note,
      });

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create cash mutation response payload'),
        );
      }

      return Result.success(CashMutation.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
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
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('cashMutation.transfer', {
        'fromAccountId': fromAccountId,
        'toAccountId': toAccountId,
        'amount': amount,
        'happenedAt': happenedAt.toIso8601String(),
        if (note != null && note.isNotEmpty) 'note': note,
      });

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid transfer cash response payload'),
        );
      }

      return Result.success(CashMutation.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<void, Failure>> delete({required int id}) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      await socket.rpc('cashMutation.delete', {'id': id});
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
