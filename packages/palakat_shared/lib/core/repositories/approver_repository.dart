import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/approver.dart';
import '../models/approval_status.dart';
import '../models/request/request.dart';
import '../models/response/response.dart';
import '../models/result.dart';
import '../services/socket_service.dart';

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
      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('approver.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Approver.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Fetch a single approver by ID
  Future<Result<Approver, Failure>> fetchApprover({
    required int approverId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('approver.get', {'id': approverId});
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid approver response payload'));
      }
      return Result.success(Approver.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Update an approver
  Future<Result<Approver, Failure>> updateApprover({
    required int approverId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('approver.update', {
        'id': approverId,
        'dto': update,
      });

      final data = body;
      developer.log(
        'updateApprover response: $data',
        name: 'ApproverRepository',
      );

      final Map<String, dynamic> json =
          (data['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update approver response payload'),
        );
      }

      return Result.success(Approver.fromJson(json));
    } catch (e, st) {
      developer.log(
        'updateApprover error: $e',
        name: 'ApproverRepository',
        error: e,
        stackTrace: st,
      );
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Create an approver
  Future<Result<Approver, Failure>> createApprover({
    required Map<String, dynamic> data,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('approver.create', data);
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create approver response payload'),
        );
      }
      return Result.success(Approver.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  /// Delete an approver
  Future<Result<void, Failure>> deleteApprover({
    required int approverId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      await socket.rpc('approver.delete', {'id': approverId});
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
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
