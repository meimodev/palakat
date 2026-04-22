import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/cash_account.dart';
import '../models/response/response.dart';
import '../models/result.dart';
import '../services/socket_service.dart';

part 'cash_account_repository.g.dart';

/// Riverpod provider for [CashAccountRepository].
@riverpod
CashAccountRepository cashAccountRepository(Ref ref) =>
    CashAccountRepository(ref);

/// Repository that fetches church-scoped cash accounts via the WS RPC layer.
class CashAccountRepository {
  CashAccountRepository(this._ref);

  final Ref _ref;

  /// Fetches a page of cash accounts belonging to the current user's church.
  Future<Result<PaginationResponseWrapper<CashAccount>, Failure>> fetchAccounts({
    int page = 1,
    int pageSize = 100,
    String? search,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    try {
      final Map<String, dynamic> query = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };
      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }

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

  /// Fetches a single cash account by id.
  Future<Result<CashAccount, Failure>> fetchAccount({required int id}) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('cashAccount.get', {'id': id});
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid cash account response payload'),
        );
      }
      return Result.success(CashAccount.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
