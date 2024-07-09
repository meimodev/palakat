import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/data_sources/data_sources.dart';
import 'package:palakat/core/models/models.dart';

class AccountRepository {
  AccountRepository({
    required this.accountApi,
    required this.membershipApi,
  });

  final AccountApiContract accountApi;
  final MembershipApiContract membershipApi;

  Future<Result<Account>> getAccount(String uid) async {
    final res = await accountApi.getAccount(uid);
    return res.when(
      success: (data) => Result.success(
        Account.fromJson(data),
      ),
      failure: Result.failure,
    );
  }

  Future<Result<Membership?>> getMembership(String membershipSerial) async {
    final res = await membershipApi.getMembership(
      membershipSerial,
    );
    return res.when(
      success: (data) {
        if (data.isEmpty) {
          return const Result.success(null);
        }
        return Result.success(
          Membership.fromJson(data),
        );
      },
      failure: Result.failure,
    );
  }
}

final accountRepositoryProvider =
    Provider.autoDispose<AccountRepository>((ref) {
  return AccountRepository(
    accountApi: ref.read(accountApiProvider),
    membershipApi: ref.read(membershipApiProvider),
  );
});
