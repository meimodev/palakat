import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/approval_rule.dart';
import '../models/member_position.dart';
import '../models/request/request.dart';
import '../models/response/response.dart';
import '../models/result.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';
import '../config/endpoint.dart';

part 'approval_repository.g.dart';

/// Repository for managing approval rules and configurations
class ApprovalRepository {
  final Ref _ref;
  
  ApprovalRepository(this._ref);
  
  /// Fetch approval rules with pagination
  Future<Result<PaginationResponseWrapper<ApprovalRule>, Failure>> fetchApprovalRules({
    required PaginationRequestWrapper<GetFetchApprovalRulesRequest> paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final query = paginationRequest.toJsonFlat((p) => p.toJson());
      
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.approvalRules,
        queryParameters: query,
      );
      
      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => ApprovalRule.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch approval rules');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch approval rules', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  /// Fetch membership positions with pagination
  Future<Result<PaginationResponseWrapper<MemberPosition>, Failure>> fetchMembershipPositions({
    required PaginationRequestWrapper<GetFetchPositionsRequest> paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final query = paginationRequest.toJsonFlat((p) => p.toJson());
      
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.membershipPositions,
        queryParameters: query,
      );
      
      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => MemberPosition.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch positions');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch positions', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  /// Fetch a single approval rule by ID
  Future<Result<ApprovalRule, Failure>> fetchApprovalRuleById(int ruleId) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.approvalRule(ruleId.toString()),
      );
      
      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid approval rule response payload'));
      }
      
      return Result.success(ApprovalRule.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch approval rule');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch approval rule', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  /// Create a new approval rule
  Future<Result<ApprovalRule, Failure>> createApprovalRule(Map<String, dynamic> data) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.approvalRules,
        data: data,
      );
      
      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid create approval rule response payload'));
      }
      
      return Result.success(ApprovalRule.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to create approval rule');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to create approval rule', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  /// Update an existing approval rule
  Future<Result<ApprovalRule, Failure>> updateApprovalRule({
    required int ruleId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.approvalRule(ruleId.toString()),
        data: data,
      );
      
      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid update approval rule response payload'));
      }
      
      return Result.success(ApprovalRule.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to update approval rule');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to update approval rule', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  /// Delete an approval rule
  Future<Result<void, Failure>> deleteApprovalRule(int ruleId) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete(Endpoints.approvalRule(ruleId.toString()));
      return Result.success(null);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to delete approval rule');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to delete approval rule', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }
}

/// Riverpod provider for ApprovalRepository
@riverpod
ApprovalRepository approvalRepository(Ref ref) {
  return ApprovalRepository(ref);
}

