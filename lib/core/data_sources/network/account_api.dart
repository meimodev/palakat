import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/constants/endpoint/endpoint.dart';
import 'package:palakat/core/data_sources/data_sources.dart';
import 'package:palakat/core/models/models.dart';

import 'dio_client.dart';

class AccountApi implements AccountApiContract {
  final DioClient _dio;
  final HiveService _hive;

  AccountApi(this._dio, this._hive);

  @override
  Future<Result<Map<String, dynamic>?, Failure>> getSignedInAccount() async {
    //Biasanya ini ada request ke API di server, tapi disini cuma read dri local storage
    try {
      final result = _hive.getAccount();
      return Result.success(result?.toJson());
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<Map<String, dynamic>, Failure>> signIn(Account account) async {
    //Biasanya ini ada request ke API di server, tapi disini cuma save ke local storage
    // karna utk session & token dihandle di firebase auth
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

final accountApiProvider = Provider<AccountApiContract>((ref) {
  return AccountApi(ref.read(dioClientProvider), ref.read(hiveServiceProvider));
});
