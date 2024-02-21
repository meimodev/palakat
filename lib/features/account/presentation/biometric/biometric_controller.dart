import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/biometric.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/presentation.dart';

class BiometricController extends StateNotifier<BiometricState> {
  final AccountService accountService;
  final BuildContext context;

  BiometricController(
    this.context,
    this.accountService,
  ) : super(const BiometricState());

  Future<bool> init() async {
    bool isSupport = await Biometric.checkIfSupport();

    if (!isSupport) {
      if (context.mounted) context.goNamed(AppRoute.home);
      Snackbar.error(
        message: LocaleKeys.text_yourDeviceNotSupportedBiometricSecurity.tr(),
      );
      return false;
    }

    final accountSetting = accountService.getAccountSetting();

    state = state.copyWith(
      biometricType: await Biometric.getAvailableBiometrics(),
      isLoading: false,
      enableBiometric: accountSetting.enableBiometric,
    );

    return true;
  }

  void setBiometric(bool value) async {
    if (value) {
      bool isAuthenticated = await Biometric.authenticate();

      if (!isAuthenticated) return;
    }

    state = state.copyWith(enableBiometric: value);

    accountService.setEnableBiometric(value);
  }
}

final biometricControllerProvider = StateNotifierProvider.family<
    BiometricController, BiometricState, BuildContext>(
  (ref, context) {
    return BiometricController(
      context,
      ref.read(accountServiceProvider),
    );
  },
);
