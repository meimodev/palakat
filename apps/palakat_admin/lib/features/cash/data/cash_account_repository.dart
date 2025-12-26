import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/services.dart';

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
      final query = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('cashAccount.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => CashAccount.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<CashAccount, Failure>> create({
    required String name,
    String? currency,
    int? openingBalance,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('cashAccount.create', {
        'name': name,
        if (currency != null && currency.isNotEmpty) 'currency': currency,
        if (openingBalance != null) 'openingBalance': openingBalance,
      });

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create cash account response payload'),
        );
      }

      return Result.success(CashAccount.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<CashAccount, Failure>> update({
    required int id,
    String? name,
    String? currency,
    int? openingBalance,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('cashAccount.update', {
        'id': id,
        'dto': {
          if (name != null) 'name': name,
          if (currency != null) 'currency': currency,
          if (openingBalance != null) 'openingBalance': openingBalance,
        },
      });

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update cash account response payload'),
        );
      }

      return Result.success(CashAccount.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<void, Failure>> delete({required int id}) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      await socket.rpc('cashAccount.delete', {'id': id});
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
