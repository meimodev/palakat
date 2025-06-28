import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'contracts/contract.dart';

class AccountApi implements AccountApiContract {


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


}

final accountApiProvider = Provider<AccountApi>((ref) {
  return AccountApi();
});
