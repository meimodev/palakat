import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/core/constants/endpoint/endpoint.dart';
import 'package:palakat/core/data_sources/data_sources.dart';
import 'package:palakat/core/models/models.dart';

import 'dio_client.dart';

part 'account_api.g.dart';

@riverpod
class AccountApi extends _$AccountApi implements AccountApiContract {
  @override
  AccountApiContract build() {
    return this;
  }

  DioClient get _dio => ref.read(dioClientProvider());
  HiveService get _hive => ref.read(hiveServiceProvider);

  @override
  Future<Result<Map<String, dynamic>?, Failure>> getSignedInAccount() async {
    try {
      final result = _hive.getAccount();
      return Result.success(result?.toJson());
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> signIn(Account account) async {
    try {
      _hive.saveAccount(account);
      return Result.success(account.toJson());
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
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
      return Result.success(response['data']);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}

