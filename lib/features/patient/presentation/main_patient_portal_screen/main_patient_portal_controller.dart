import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/enums/enums.dart';
import 'package:halo_hermina/core/datasources/network/model/network_exceptions.dart';
import 'package:halo_hermina/core/utils/biometric.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/presentation.dart';

class MainPatientPortalController
    extends StateNotifier<MainPatientPortalState> {
  MainPatientPortalController(
    this._accountService,
    this._authService,
    this._patientService,
  ) : super(
          MainPatientPortalState(
            loading: true,
            patientPortalStatus: PatientPortalStatus.activated,
            authorized: false,
          ),
        );

  final AccountService _accountService;
  final AuthenticationService _authService;
  final PatientService _patientService;

  final inputPinTextController = TextEditingController();

  bool get loggedIn => _authService.isLoggedIn;

  void init(Future<Object?> Function() onOpenLoginScreen) async {
    if (!loggedIn) {
      onPressedLogin(onOpenLoginScreen);
      return;
    }
    state = state.copyWith(loading: true);

    await checkPatientPortalStatus();
    await checkLocalAccountSetting();
  }

  void onPressedLogin(Future<Object?> Function() onOpenLoginScreen) async {
    state = state.copyWith(loading: false);
    final result = await onOpenLoginScreen();
    if (result == null) {
      return;
    }
    state = state.copyWith(loading: true);

    await checkPatientPortalStatus();
    await checkLocalAccountSetting();
  }

  Future<void> checkPatientPortalStatus() async {
    final profile = await _patientService.checkPatientPortalStatus();
    profile.when(
      success: (data) {
        state = state.copyWith(
          patientPortalStatus: data,
          loading: false,
        );

        print("Patient Portal response data ${data.label}");
      },
      failure: (NetworkExceptions error, StackTrace stackTrace) {
        state = state.copyWith(loading: false);
        final message = NetworkExceptions.getErrorMessage(error);
        Snackbar.error(message: message);
      },
    );
  }

  Future<void> checkLocalAccountSetting() async {
    final accountSetting = _accountService.getAccountSetting();
    state = state.copyWith(
      authorized: accountSetting.authenticatedPatientPortal,
      loading: false,
      canUseBiometric: accountSetting.enableBiometric,
      biometricType: accountSetting.enableBiometric
          ? await Biometric.getAvailableBiometrics()
          : [],
    );
  }

  void setAuthorized(bool authorized) {
    state = state.copyWith(authorized: authorized);
  }

  void loginByBiometric() async {
    final authenticated = await Biometric.authenticate();

    if (authenticated) {
      _accountService.setAuthenticatedPatientPortal(true);
      setAuthorized(true);
    }
  }
}

final mainPatientPortalController = StateNotifierProvider.autoDispose<
    MainPatientPortalController, MainPatientPortalState>((ref) {
  return MainPatientPortalController(
    ref.read(accountServiceProvider),
    ref.read(authenticationServiceProvider),
    ref.read(patientServiceProvider),
  );
});
