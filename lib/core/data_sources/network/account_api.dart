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
    // di class api ini baru boleh panggil api yang bersangkutan karna biasanya disini banyak error catching yg terjadi
    // nanti hasil dari error catching itu + response body hasil fetch yang di passing ke repository untuk di transformasi
    // pake helper class Result biar lebe rapi

    try {
      final result = await _dio.get<Map<String, dynamic>?>(
        Endpoint.validatePhone,
        queryParameters: {'phone': phone},
      );
      return Result.success(result!["data"]);
    } catch (e) {
      return Result.failure(Failure(e.toString()));
    }
  }
}

final accountApiProvider = Provider<AccountApi>((ref) {
  return AccountApi(ref.read(dioClientProvider));
});
