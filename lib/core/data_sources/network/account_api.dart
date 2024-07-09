import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/utils/utils.dart';

import 'contracts/contract.dart';
import 'model/model.dart';

class AccountApi implements AccountApiContract {

  final accounts = FirestoreUtil.accounts;

  @override
  Future<Result<Map<String, dynamic>>> getAccount(String uid) async {
    try {
      final res = await accounts
          .where(
            "uid",
            isEqualTo: uid,
          )
          .get();
      return Result.success(res.docs.firstOrNull?.data() ?? {});
    } catch (e, st) {
      Result.failure(e, st);
    }
    throw UnimplementedError();
  }

  @override
  Future<Result<Map<String, dynamic>>> signIn() {
    // TODO: implement signIn
    throw UnimplementedError();
  }

  @override
  Future<Result<Map<String, dynamic>>> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<Result<Map<String, dynamic>>> signUp() {
    // TODO: implement signUp
    throw UnimplementedError();
  }

// Future<Result<dynamic>> userFeature({
//   Map<String, dynamic>? params,
// }) async {
//   try {
//     final response = await _dioClient.get(
//       Endpoint.userFeature,
//       queryParameters: params,
//     );
//     return Result.success(
//       List.from(
//         (response['data'] as List).map(
//           (e) => UserFeatureResponse.fromJson(e),
//         ),
//       ),
//     );
//   } catch (e, st) {
//     return Result.failure(
//       NetworkExceptions.getDioException(e, st),
//       st,
//     );
//   }
// }
}

final accountApiProvider = Provider<AccountApi>((ref) {
  return AccountApi();
});
