import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat/core/data_sources/data_sources.dart';
import 'package:palakat/core/models/models.dart';

class AccountRepository {
  final AccountApiContract _accountApi;

  AccountRepository(this._accountApi);

  Future<Result<Account?, Failure>> checkSignedInAccount() async {
    // call firebase auth api -> check user signed in ad d p function dari d p package
    // kalo signed in, return account pake validateAccountByPhone(phone)
    // kalo signed out, return null

    // cuman ini pake dummy dlu
    return Result.success(null);
  }

  // kalo d p response ada pagination, d p parameter bagusnya pake wrapper class for pagination
  Future<Result<Account, Failure>> validateAccountByPhone(String phone) async {
    // kalo dari class yang panggil api langsung, returnnya berupa raw data langsung
    // langsung dari JSON yang dari body response yang so convert jadi Map<String, dynamic>
    // di class repository baru trng transform ke model ato transformasi laeng dari class api yang lain
    // biasanya di transform di repository / panggil beberapa api dari yang lain disini biar di controller tinggal panggil 1 function ini saja per kebutuhan
    try {
      final result = await _accountApi.getAccountByPhone(phone);

      return result.mapTo<Account, Failure>(
        onSuccess: (data) {
          try {
            final account = Account.fromJson(Map<String, dynamic>.from(data));
            return account;
          } catch (e) {
            throw e;
          }
        },
      );
    } catch (e) {
      return Result.failure(Failure("Repository error: ${e.toString()}"));
    }
  }
}

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.read(accountApiProvider));
});
