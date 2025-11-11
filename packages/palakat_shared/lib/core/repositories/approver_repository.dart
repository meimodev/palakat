import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/approver.dart';
import '../models/approval_status.dart';
import '../models/request/request.dart';
import '../models/response/response.dart';
import '../models/result.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';
import '../config/endpoint.dart';

part 'approver_repository.g.dart';

@riverpod
ApproverRepository approverRepository(Ref ref) => ApproverRepository(ref);

class ApproverRepository {
  ApproverRepository(this._ref);

  final Ref _ref;

  /// Fetch approvers with pagination
  Future<Result<PaginationResponseWrapper<Approver>, Failure>> fetchApprovers({
    required PaginationRequestWrapper paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.approvers,
        queryParameters: query,
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Approver.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch approvers');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch approvers', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  /// Fetch a single approver by ID
  Future<Result<Approver, Failure>> fetchApprover({required int approverId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.approver(approverId),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid approver response payload'));
      }
      return Result.success(Approver.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch approver');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch approver', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  /// Update an approver
  Future<Result<Approver, Failure>> updateApprover({
    required int approverId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.approver(approverId),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid update approver response payload'));
      }

      return Result.success(Approver.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to update approver');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to update approver', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  /// Create an approver
  Future<Result<Approver, Failure>> createApprover({required Map<String, dynamic> data}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.approvers,
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid create approver response payload'));
      }
      return Result.success(Approver.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to create approver');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to create approver', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  /// Delete an approver
  Future<Result<void, Failure>> deleteApprover({required int approverId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.approver(approverId));
      return Result.success(null);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to delete approver');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to delete approver', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  /// Get status display information for approval status
  StatusDisplay getStatusDisplay(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.unconfirmed:
        return StatusDisplay(
          label: 'Unconfirmed',
          colorValue: Colors.grey.shade600.toARGB32(),
          icon: Icons.help_outline,
        );
      case ApprovalStatus.approved:
        return StatusDisplay(
          label: 'Approved',
          colorValue: Colors.green.shade600.toARGB32(),
          icon: Icons.check_circle_outline,
        );
      case ApprovalStatus.rejected:
        return StatusDisplay(
          label: 'Rejected',
          colorValue: Colors.red.shade600.toARGB32(),
          icon: Icons.cancel_outlined,
        );
    }
  }
}

/// Status display model
class StatusDisplay {
  final String label;
  final int colorValue;
  final IconData icon;

  StatusDisplay({
    required this.label,
    required this.colorValue,
    required this.icon,
  });
}
