import 'package:palakat_shared/core/models/finance_type.dart';
import 'package:palakat_shared/core/models/financial_account_number.dart';
import 'package:palakat_shared/core/models/response/pagination_response_wrapper.dart';
import 'package:palakat_shared/core/models/result.dart';
import 'package:palakat_shared/core/services/socket_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'financial_account_repository.g.dart';

/// Riverpod provider for FinancialAccountRepository
@riverpod
FinancialAccountRepository financialAccountRepository(Ref ref) =>
    FinancialAccountRepository(ref);

/// Abstract interface for financial account number data operations
abstract class FinancialAccountRepositoryBase {
  /// Fetches list of financial account numbers with pagination
  Future<Result<PaginationResponseWrapper<FinancialAccountNumber>, Failure>>
  getAll({
    required int churchId,
    int page = 1,
    int pageSize = 20,
    String? search,
    FinanceType? type,
  });
}

/// Implementation of FinancialAccountRepository for API operations
class FinancialAccountRepository implements FinancialAccountRepositoryBase {
  FinancialAccountRepository(this._ref);

  final Ref _ref;

  @override
  Future<Result<PaginationResponseWrapper<FinancialAccountNumber>, Failure>>
  getAll({
    required int churchId,
    int page = 1,
    int pageSize = 20,
    String? search,
    FinanceType? type,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'churchId': churchId,
        'page': page,
        'pageSize': pageSize,
      };
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (type != null) {
        queryParameters['type'] = type.value;
      }

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc(
        'financialAccountNumber.list',
        queryParameters,
      );
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => FinancialAccountNumber.fromJson(e as Map<String, dynamic>),
      );

      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
