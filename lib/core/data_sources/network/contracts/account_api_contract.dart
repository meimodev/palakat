import 'package:palakat/core/data_sources/data_sources.dart';
import 'package:palakat/core/models/models.dart';

abstract class AccountApiContract {
  Future<Result<Map<String, dynamic>?, Failure>> getSignedInAccount();

  Future<Result<Map<String, dynamic>, Failure>> getAccountByPhone(String phone);

  Future<Result<Map<String, dynamic>, Failure>> signIn(Account account);

  Future<Map<String, dynamic>> signOut();

  Future<Map<String, dynamic>> signUp();
}
