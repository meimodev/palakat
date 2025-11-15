import 'package:dio/dio.dart';
// import 'package:palakat_shared/features/member/presentation/state/member_screen_state.dart';
import 'package:palakat_shared/core/models/member_position.dart';
import 'package:palakat_shared/core/models/membership.dart';
import 'package:palakat_shared/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/endpoint.dart';
import '../models/account.dart';
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

  // Future<Account> createAccount({required Map<String, dynamic> data}) async {
  //   try {
  //     final http = _ref.read(httpServiceProvider);
  //     final response = await http.post<Map<String, dynamic>>(
  //       Endpoints.accounts,
  //       data: data,
  //     );
  //
  //     final body = response.data;
  //     final Map<String, dynamic> json = body?['data'] ?? {};
  //     if (json.isEmpty) {
  //       throw AppError.network('Invalid create account response payload');
  //     }
  //     return Account.fromJson(json);
  //   } on DioException catch (e) {
  //     throw ErrorMapper.fromDio(e, 'Failed to create account');
  //   } catch (e) {
  //     throw ErrorMapper.unknown('Failed to create account', e);
  //   }
  // }

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

  // TODO: Move MemberScreenStateCounts to shared package or implement in consuming app
  // Future<Result<MemberScreenStateCounts, Failure>> fetchCounts(
  //   GetFetchAccountsRequest request,
  // ) async {
  //   try {
  //     final http = _ref.read(httpServiceProvider);
  //
  //     final response = await http.get<Map<String, dynamic>>(
  //       Endpoints.accountCount,
  //       queryParameters: request.toJson(),
  //     );
  //
  //     final data = response.data;
  //     final Map<String, dynamic> json = data?['data'] ?? {};
  //     if (json.isEmpty) {
  //       return Result.failure(
  //         Failure('Invalid fetch account counts response payload'),
  //       );
  //     }
  //
  //     return Result.success(MemberScreenStateCounts.fromJson(json));
  //   } on DioException catch (e, st) {
  //     final error = ErrorMapper.fromDio(
  //       e,
  //       'Failed to fetch account counts',
  //       st,
  //     );
  //     return Result.failure(Failure(error.message, error.statusCode));
  //   } catch (e, st) {
  //     final error = ErrorMapper.unknown(
  //       'Failed to fetch account counts',
  //       e,
  //       st,
  //     );
  //     return Result.failure(Failure(error.message, error.statusCode));
  //   }
  // }

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

  Future<Result<PaginationResponseWrapper<MemberPosition>, Failure>>
  fetchMemberPositionsPagination({
    required PaginationRequestWrapper<GetFetchMemberPosition> paginationRequest,
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
      final error = ErrorMapper.fromDio(e, 'Failed to fetch member positions');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown(
        'Failed to fetch member positions',
        e,
        st,
      );
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  Future<Result<Membership, Failure>> getMembership(int membershipId) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.membership(membershipId: membershipId),
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid fetch membership response payload'),
        );
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
}
