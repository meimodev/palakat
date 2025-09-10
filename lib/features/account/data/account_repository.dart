import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/core/data_sources/data_sources.dart';
import 'package:palakat/core/models/models.dart';

part 'account_repository.g.dart';

@riverpod
class AccountRepository extends _$AccountRepository {
  @override
  AccountRepository build() {
    return this;
  }

  AccountApiContract get _accountApi => ref.read(accountApiProvider);

  Future<Result<Account?, Failure?>> getSignedInAccount() async {
    final result = await _accountApi.getSignedInAccount();
    return result.mapTo<Account?, Failure?>(
      onSuccess: (data) => data == null ? null : Account.fromJson(data),
    );
  }

  Future<Result<Account, Failure>> signIn(Account account) async {
    final result = await _accountApi.signIn(account);
    return result.mapTo<Account, Failure>(onSuccess: Account.fromJson);
  }

  Future<Result<Account, Failure>> validateAccountByPhone(String phone) async {
    final result = await _accountApi.getAccountByPhone(phone);
    return result.mapTo<Account, Failure>(onSuccess: Account.fromJson);
  }
}
