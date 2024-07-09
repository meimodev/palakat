
import 'package:palakat/core/data_sources/network/model/model.dart';

abstract class AccountApiContract{
  Future<Result<Map<String, dynamic>>> getAccount(String uid);
  Future<Result<Map<String, dynamic>>> signIn();
  Future<Result<Map<String, dynamic>>> signOut();
  Future<Result<Map<String, dynamic>>> signUp();

}