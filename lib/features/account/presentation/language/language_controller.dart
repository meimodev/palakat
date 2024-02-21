import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:restart_app/restart_app.dart';

class LanguageController extends StateNotifier<LanguageState> {
  final AccountService _accountService;
  final BuildContext context;

  final List<LanguageKey> languageSetting = [
    LanguageKey.en,
    LanguageKey.id,
  ];

  LanguageController(this._accountService, this.context)
      : super(
          const LanguageState(),
        ) {
    init();
  }

  void init() async {
    final accountSetting = _accountService.getAccountSetting();

    state = state.copyWith(
      isLoading: false,
      language: accountSetting.language.languageKey,
    );
  }

  void setLanguage(LanguageKey value) async {
    state = state.copyWith(language: value);
  }

  void saveLanguage() async {
    state = state.copyWith(isLoading: true);

    await _accountService.saveLanguage(state.language);

    if (context.mounted) context.setLocale(state.language.locale);

    await Restart.restartApp();

    state = state.copyWith(isLoading: false);
  }
}

final languageControllerProvider = StateNotifierProvider.family<
    LanguageController, LanguageState, BuildContext>(
  (ref, context) {
    return LanguageController(ref.read(accountServiceProvider), context);
  },
);
