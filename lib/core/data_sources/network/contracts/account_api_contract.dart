

import 'package:palakat/core/data_sources/data_sources.dart';

abstract class AccountApiContract{
  Future<Map<String, dynamic>> getAccount(String uid);
  Future<Result<Map<String, dynamic>, Failure>> getAccountByPhone(String phone);
  Future<Map<String, dynamic>> signIn();
  Future<Map<String, dynamic>> signOut();
  Future<Map<String, dynamic>> signUp();

}