import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/approval_rule.dart';
import '../models/financial_account_number.dart';
import '../models/member_position.dart';
import '../models/request/request.dart';
import '../models/response/response.dart';
import '../models/result.dart';
import '../services/socket_service.dart';

part 'approval_repository.g.dart';

/// Repository for managing approval rules and configurations
class ApprovalRepository {
  final Ref _ref;

  ApprovalRepository(this._ref);

  /// Fetch approval rules with pagination
  Future<Result<PaginationResponseWrapper<ApprovalRule>, Failure>>
  fetchApprovalRules({
    required PaginationRequestWrapper<GetFetchApprovalRulesRequest>
    paginationRequest,
  }) async {
    try {
      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('approvalRule.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => ApprovalRule.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Fetch membership positions with pagination
  Future<Result<PaginationResponseWrapper<MemberPosition>, Failure>>
  fetchMembershipPositions({
    required PaginationRequestWrapper<GetFetchPositionsRequest>
    paginationRequest,
  }) async {
    try {
      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('membershipPosition.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => MemberPosition.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Fetch a single approval rule by ID
  Future<Result<ApprovalRule, Failure>> fetchApprovalRuleById(
    int ruleId,
  ) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('approvalRule.get', {'id': ruleId});
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid approval rule response payload'),
        );
      }

      return Result.success(ApprovalRule.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Create a new approval rule
  Future<Result<ApprovalRule, Failure>> createApprovalRule(
    Map<String, dynamic> data,
  ) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('approvalRule.create', data);
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create approval rule response payload'),
        );
      }

      return Result.success(ApprovalRule.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Update an existing approval rule
  Future<Result<ApprovalRule, Failure>> updateApprovalRule({
    required int ruleId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('approvalRule.update', {
        'id': ruleId,
        'dto': data,
      });
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update approval rule response payload'),
        );
      }

      return Result.success(ApprovalRule.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Delete an approval rule
  Future<Result<void, Failure>> deleteApprovalRule(int ruleId) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      await socket.rpc('approvalRule.delete', {'id': ruleId});
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Fetch financial account numbers for approval rule configuration
  ///
  /// Filters by [churchId] and optionally by [type] (REVENUE or EXPENSE).
  /// Used for populating the financial account dropdown in approval rule forms.
  Future<Result<List<FinancialAccountNumber>, Failure>>
  fetchFinancialAccountNumbers({required int churchId, String? type}) async {
    try {
      final query = <String, dynamic>{
        'churchId': churchId,
        'page': 1,
        'pageSize': 100, // Get all accounts for dropdown
      };
      if (type != null) {
        query['type'] = type;
      }

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('financialAccountNumber.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => FinancialAccountNumber.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result.data);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Fetch available financial account numbers that are not linked to any approval rule
  ///
  /// Filters by [churchId] and optionally by [type] (REVENUE or EXPENSE).
  /// When [currentRuleId] is provided, includes the account linked to that rule
  /// (useful when editing an existing rule).
  Future<Result<List<FinancialAccountNumber>, Failure>> getAvailableAccounts({
    required int churchId,
    String? type,
    int? currentRuleId,
  }) async {
    try {
      final query = <String, dynamic>{
        'churchId': churchId,
        'page': 1,
        'pageSize': 100,
      };
      if (type != null) {
        query['type'] = type;
      }
      if (currentRuleId != null) {
        query['currentRuleId'] = currentRuleId;
      }

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('financialAccountNumber.available', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => FinancialAccountNumber.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result.data);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}

/// Riverpod provider for ApprovalRepository
@riverpod
ApprovalRepository approvalRepository(Ref ref) {
  return ApprovalRepository(ref);
}
