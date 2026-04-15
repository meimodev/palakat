import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/approver.dart';
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
  final bool? standalone;

  const GetFetchFinanceEntriesRequest({
    this.search,
    this.paymentMethod,
    this.type,
    this.startDate,
    this.endDate,
    this.standalone,
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
      if (standalone == true) 'standalone': true,
    };
  }
}

abstract class FinanceRepositoryBase {
  Future<Result<FinanceOverview, Failure>> fetchOverview();
  Future<Result<PaginationResponseWrapper<FinanceEntry>, Failure>>
  fetchFinanceEntries({required PaginationRequestWrapper paginationRequest});
  Future<Result<PaginationResponseWrapper<FinanceEntry>, Failure>>
  fetchApprovalFinanceEntries({
    required PaginationRequestWrapper paginationRequest,
  });
  Future<Result<FinanceEntry, Failure>> fetchFinanceEntry({
    required int financeId,
    required FinanceEntryType type,
  });
  Future<Result<FinanceEntry, Failure>> fetchApprovalFinanceEntry({
    required int financeId,
    required FinanceEntryType type,
  });
  Future<Result<Approver, Failure>> updateFinanceApprover({
    required int approverId,
    required FinanceEntryType type,
    required ApprovalStatus status,
  });
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

  @override
  Future<Result<PaginationResponseWrapper<FinanceEntry>, Failure>>
  fetchApprovalFinanceEntries({
    required PaginationRequestWrapper paginationRequest,
  }) async {
    try {
      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('finance.approval.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => FinanceEntry.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<FinanceEntry, Failure>> fetchFinanceEntry({
    required int financeId,
    required FinanceEntryType type,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('finance.get', {
        'id': financeId,
        'financeType': type.name.toUpperCase(),
      });

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid finance response payload'));
      }

      return Result.success(FinanceEntry.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<FinanceEntry, Failure>> fetchApprovalFinanceEntry({
    required int financeId,
    required FinanceEntryType type,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('finance.approval.get', {
        'id': financeId,
        'financeType': type.name.toUpperCase(),
      });

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid finance approval response payload'),
        );
      }

      return Result.success(FinanceEntry.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<Approver, Failure>> updateFinanceApprover({
    required int approverId,
    required FinanceEntryType type,
    required ApprovalStatus status,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('finance.approver.update', {
        'approverId': approverId,
        'financeType': type.name.toUpperCase(),
        'dto': {'status': status.name.toUpperCase()},
      });

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid finance approver response payload'),
        );
      }

      return Result.success(Approver.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Admin override: force a specific status on any finance approver.
  /// Requires an admin-app session (aud:'admin') and override permission.
  Future<Result<Approver, Failure>> overrideFinanceApprover({
    required int approverId,
    required FinanceEntryType type,
    required ApprovalStatus status,
    String? note,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('finance.approver.override', {
        'approverId': approverId,
        'financeType': type.name.toUpperCase(),
        'status': status == ApprovalStatus.approved ? 'APPROVED' : 'REJECTED',
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      });

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid finance approver override response payload'),
        );
      }

      return Result.success(Approver.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
