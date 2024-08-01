import 'package:palakat/features/presentation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_controller.g.dart';

@riverpod
class AccountController extends _$AccountController {

  @override
  AccountState build() {
    return const AccountState(
    account: null,
      submitLoading: false,
      loading: true,
     errorTextPhone : "",
     errorTextName : "",
     errorTextDob : "",
     errorTextGender : "",
     errorTextMaritalStatus : "",
    );
  }
}
