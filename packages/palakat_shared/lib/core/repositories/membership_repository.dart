import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/account.dart';
import '../models/membership.dart';
import '../models/request/request.dart';
import '../models/response/response.dart';
import '../models/result.dart';
import '../services/socket_service.dart';

part 'membership_repository.g.dart';

@riverpod
MembershipRepository membershipRepository(Ref ref) => MembershipRepository(ref);

class MembershipRepository {
  MembershipRepository(this._ref);

  final Ref _ref;

  Future<Result<PaginationResponseWrapper<Account>, Failure>> fetchAccounts({
    required PaginationRequestWrapper<GetFetchAccountsRequest>
    paginationRequest,
  }) async {
    try {
      final query = paginationRequest.toJsonFlat((p) => p.toJson());
      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('account.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Account.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<Map<String, int>, Failure>> fetchCounts(
    GetFetchAccountsRequest request,
  ) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final response = await socket.rpc('account.count', request.toJson());

      final data = response['data'] as Map<String, dynamic>? ?? {};
      final counts = data.map((key, value) => MapEntry(key, value as int));
      return Result.success(counts);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<PaginationResponseWrapper<Membership>, Failure>>
  fetchMemberPositionsPagination({
    required PaginationRequestWrapper<GetFetchMemberPosition> paginationRequest,
  }) async {
    try {
      final query = paginationRequest.toJsonFlat((p) => p.toJson());
      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('membership.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Membership.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<Account, Failure>> fetchAccount({
    required int accountId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('account.get', {
        'id': accountId.toString(),
      });
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid account response payload'));
      }
      return Result.success(Account.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<Account, Failure>> createAccount({
    required Map<String, dynamic> data,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('account.create', data);
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create account response payload'),
        );
      }
      return Result.success(Account.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<Account, Failure>> updateAccount({
    required int accountId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('account.update', {
        'id': accountId,
        'dto': update,
      });
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update account response payload'),
        );
      }
      return Result.success(Account.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<void, Failure>> deleteAccount({required int accountId}) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      await socket.rpc('account.delete', {'id': accountId});
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<Membership, Failure>> fetchMembership({
    required int membershipId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('membership.get', {'id': membershipId});
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid membership response payload'));
      }
      return Result.success(Membership.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  // Alias for backward compatibility
  Future<Result<Membership, Failure>> getMembership(int membershipId) {
    return fetchMembership(membershipId: membershipId);
  }

  Future<Result<Membership, Failure>> createMembership({
    required Map<String, dynamic> data,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('membership.create', data);
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create membership response payload'),
        );
      }
      return Result.success(Membership.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<Membership, Failure>> updateMembership({
    required int membershipId,
    Map<String, dynamic>? update,
    Map<String, dynamic>? data,
  }) async {
    try {
      final payload = update ?? data;
      if (payload == null) {
        return Result.failure(
          Failure('Either update or data parameter must be provided'),
        );
      }

      final socket = _ref.read(socketServiceProvider);
      final responseData = await socket.rpc('membership.update', {
        'id': membershipId,
        'dto': payload,
      });

      final Map<String, dynamic> json =
          (responseData['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update membership response payload'),
        );
      }
      return Result.success(Membership.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  Future<Result<void, Failure>> deleteMembership({
    required int membershipId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      await socket.rpc('membership.delete', {'id': membershipId});
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
