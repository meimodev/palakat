import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/endpoint.dart';
import '../models/account.dart';
import '../models/membership.dart';
import '../models/request/request.dart';
import '../models/response/response.dart';
import '../models/result.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';

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
      final http = _ref.read(httpServiceProvider);
      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.accounts,
        queryParameters: query,
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Account.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch accounts');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch accounts', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Map<String, int>, Failure>> fetchCounts(
    GetFetchAccountsRequest request,
  ) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        '${Endpoints.accounts}/counts',
        queryParameters: request.toJson(),
      );

      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      final counts = data.map((key, value) => MapEntry(key, value as int));
      return Result.success(counts);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch counts');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch counts', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<PaginationResponseWrapper<Membership>, Failure>>
  fetchMemberPositionsPagination({
    required PaginationRequestWrapper<GetFetchMemberPosition> paginationRequest,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.memberships,
        queryParameters: query,
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Membership.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch memberships');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch memberships', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Account, Failure>> fetchAccount({
    required int accountId,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.account(accountId),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid account response payload'));
      }
      return Result.success(Account.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch account');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch account', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Account, Failure>> createAccount({
    required Map<String, dynamic> data,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.accounts,
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create account response payload'),
        );
      }
      return Result.success(Account.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to create account');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to create account', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Account, Failure>> updateAccount({
    required int accountId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.account(accountId),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update account response payload'),
        );
      }
      return Result.success(Account.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to update account');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to update account', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<void, Failure>> deleteAccount({required int accountId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.account(accountId));
      return Result.success(null);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to delete account');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to delete account', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Membership, Failure>> fetchMembership({
    required int membershipId,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.membership(membershipId: membershipId),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid membership response payload'));
      }
      return Result.success(Membership.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch membership');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch membership', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
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
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.memberships,
        data: data,
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create membership response payload'),
        );
      }
      return Result.success(Membership.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to create membership');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to create membership', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Membership, Failure>> updateMembership({
    required int membershipId,
    Map<String, dynamic>? update,
    Map<String, dynamic>? data,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final payload = update ?? data;
      if (payload == null) {
        return Result.failure(
          Failure('Either update or data parameter must be provided'),
        );
      }

      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.membership(membershipId: membershipId),
        data: payload,
      );

      final responseData = response.data;
      final Map<String, dynamic> json = responseData?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update membership response payload'),
        );
      }
      return Result.success(Membership.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to update membership');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to update membership', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<void, Failure>> deleteMembership({
    required int membershipId,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.membership(membershipId: membershipId));
      return Result.success(null);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to delete membership');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to delete membership', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }
}
