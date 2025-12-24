import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/finance_entry.dart';
import 'package:palakat_shared/core/models/finance_overview.dart';
import 'package:palakat_shared/core/models/request/request.dart';
import 'package:palakat_shared/core/models/response/response.dart';
import 'package:palakat_shared/core/services/http_service.dart';
import 'package:palakat_shared/core/utils/error_mapper.dart';

import '../config/endpoint.dart';
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
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.financeOverview,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid finance overview response payload'),
        );
      }

      return Result.success(FinanceOverview.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch finance overview');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown(
        'Failed to fetch finance overview',
        e,
        st,
      );
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  @override
  Future<Result<PaginationResponseWrapper<FinanceEntry>, Failure>>
  fetchFinanceEntries({
    required PaginationRequestWrapper paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.finance,
        queryParameters: query,
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => FinanceEntry.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch finance entries');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown(
        'Failed to fetch finance entries',
        e,
        st,
      );
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }
}
