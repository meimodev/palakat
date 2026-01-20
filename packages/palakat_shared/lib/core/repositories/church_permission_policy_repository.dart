import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/auth_permissions.dart';
import '../models/church_permission_policy.dart';
import '../models/result.dart';
import '../services/socket_service.dart';

part 'church_permission_policy_repository.g.dart';

@riverpod
ChurchPermissionPolicyRepository churchPermissionPolicyRepository(Ref ref) {
  // ignore: deprecated_member_use
  ref.keepAlive();
  return ChurchPermissionPolicyRepository(ref);
}

class ChurchPermissionPolicyRepository {
  ChurchPermissionPolicyRepository(this._ref);

  final Ref _ref;

  Future<Result<ChurchPermissionPolicyRecord?, Failure>> fetchMyPolicy() async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('churchPermissionPolicy.getMe');
      final data = body['data'];
      if (data == null) {
        return Result.success(null);
      }
      if (data is! Map<String, dynamic>) {
        return Result.failure(Failure('Invalid permission policy payload'));
      }
      return Result.success(ChurchPermissionPolicyRecord.fromJson(data));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<ChurchPermissionPolicyRecord, Failure>> updateMyPolicy({
    required Map<String, dynamic> policy,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('churchPermissionPolicy.updateMe', {
        'policy': policy,
      });
      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        return Result.failure(
          Failure('Invalid update permission policy payload'),
        );
      }
      return Result.success(ChurchPermissionPolicyRecord.fromJson(data));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<AuthPermissions, Failure>> fetchMyPermissions() async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('auth.permissions.get');
      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        return Result.failure(Failure('Invalid permissions payload'));
      }
      return Result.success(AuthPermissions.fromJson(data));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
