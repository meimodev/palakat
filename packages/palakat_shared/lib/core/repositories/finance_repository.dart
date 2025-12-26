import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/finance_entry.dart';
import 'package:palakat_shared/core/models/finance_overview.dart';
import 'package:palakat_shared/core/models/request/request.dart';
import 'package:palakat_shared/core/models/response/response.dart';
import 'package:palakat_shared/core/services/socket_service.dart';
import '../models/result.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FinanceRepository(ref);
});

class GetFetchFinanceEntriesRequest {
  final String? search;
  final PaymentMethod? paymentMethod;
  final FinanceEntryType? type;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetFetchFinanceEntriesRequest({
    this.search,
    this.paymentMethod,
    this.type,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      if (search != null && search!.isNotEmpty) 'search': search,
      if (paymentMethod != null)
        'paymentMethod': paymentMethod == PaymentMethod.cashless
            ? 'CASHLESS'
            : 'CASH',
      if (type != null) 'type': type!.name,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
    };
  }
}

abstract class FinanceRepositoryBase {
  Future<Result<FinanceOverview, Failure>> fetchOverview();
  Future<Result<PaginationResponseWrapper<FinanceEntry>, Failure>>
  fetchFinanceEntries({required PaginationRequestWrapper paginationRequest});
}

class FinanceRepository implements FinanceRepositoryBase {
  FinanceRepository(this._ref);

  final Ref _ref;

  @override
  Future<Result<FinanceOverview, Failure>> fetchOverview() async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('finance.overview');

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid finance overview response payload'),
        );
      }

      return Result.success(FinanceOverview.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<PaginationResponseWrapper<FinanceEntry>, Failure>>
  fetchFinanceEntries({
    required PaginationRequestWrapper paginationRequest,
  }) async {
    try {
      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('finance.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => FinanceEntry.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
