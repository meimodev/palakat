import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/endpoint/endpoint.dart';
import 'package:palakat/core/data_sources/network/model/result.dart';

import 'contracts/contract.dart';
import 'dio_client.dart';

class AccountApi implements AccountApiContract {
  final DioClient _dio;

  AccountApi(this._dio);

  @override
  Future<Map<String, dynamic>> getAccount(String uid) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> signIn() {
    // TODO: implement signIn
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> signUp() {
    // TODO: implement signUp
    throw UnimplementedError();
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> getAccountByPhone(
    String phone,
  ) async {
    try {
      final response = await _dio.get(
        Endpoint.validatePhone,
        queryParameters: {'phone': phone},
      );
      if (response != null && response is Map<String, dynamic>) {
        final result = response as Map<String, dynamic>;
        if (result['message'] == 'OK' && result['data'] != null) {
          return Result.success(result['data']);
        } else if (result['message'] != 'OK') {
          return Result.failure(
            Failure("Invalid response: ${result['message']}"),
          );
        } else {
          return Result.failure(Failure("No account data found"));
        }
      } else {
        return Result.failure(Failure("Invalid response format"));
      }
    } catch (e, stackTrace) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          return Result.failure(Failure("Account not found (404)"));
        }
        return Result.failure(Failure("Dio error: ${e.message}"));
      }

      return Result.failure(Failure(e.toString()));
    }
  }
}

final accountApiProvider = Provider<AccountApiContract>((ref) {
  return AccountApi(ref.read(dioClientProvider));
});
