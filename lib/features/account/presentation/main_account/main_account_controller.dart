import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/app_info.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/account/data/local/local.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/presentation.dart';

class MainAccountController extends StateNotifier<MainAccountState> {
  final BuildContext context;
  final AuthenticationService authService;
  final AccountService accountService;

  MainAccountController(
    this.context,
    this.authService,
    this.accountService,
  ) : super(const MainAccountState()) {
    getAppVersion();
  }

  bool get isLoggedIn => authService.isLoggedIn;
  UserData? get user => accountService.user;

  List<AccountMenuModel> get menus {
    if (!isLoggedIn) {
      return <AccountMenuModel>[
        AccountMenuModel(
          icon: Assets.icons.line.language,
          title: LocaleKeys.text_language.tr(),
          route: AppRoute.language,
        ),
        AccountMenuModel(
          icon: Assets.icons.line.help,
          title: LocaleKeys.text_help.tr(),
          route: AppRoute.help,
        ),
      ];
    }

    return <AccountMenuModel>[
      AccountMenuModel(
        icon: Assets.icons.line.account,
        title: LocaleKeys.text_myProfile.tr(),
        route: AppRoute.profile,
      ),
      AccountMenuModel(
        icon: Assets.icons.line.mapPin,
        title: LocaleKeys.prefix_list.tr(namedArgs: {
          "value": LocaleKeys.text_address.tr(),
        }),
        route: AppRoute.addressList,
      ),
      AccountMenuModel(
        icon: Assets.icons.line.users,
        title: LocaleKeys.text_patientList.tr(),
        route: AppRoute.patientList,
      ),
      AccountMenuModel(
        icon: Assets.icons.line.language,
        title: LocaleKeys.text_language.tr(),
        route: AppRoute.language,
      ),
      AccountMenuModel(
        icon: Assets.icons.line.lock,
        title: LocaleKeys.text_changePassword.tr(),
        route: AppRoute.changePassword,
      ),
      AccountMenuModel(
        icon: Assets.icons.line.securityLock,
        title: LocaleKeys.text_biometricSecurity.tr(),
        route: AppRoute.biometric,
      ),
      AccountMenuModel(
        icon: Assets.icons.line.help,
        title: LocaleKeys.text_help.tr(),
        route: AppRoute.help,
      ),
      AccountMenuModel(
        icon: Assets.icons.line.signOut,
        title: LocaleKeys.text_logOut.tr(),
        onTap: () {
          showGeneralDialogWidget(
            context,
            image: Assets.images.logout.image(
              width: BaseSize.customWidth(90),
              height: BaseSize.customWidth(90),
            ),
            title: LocaleKeys.text_logOut.tr(),
            subtitle: LocaleKeys.text_areYouSureYouWantToLogout.tr(),
            primaryButtonTitle: LocaleKeys.text_no.tr(),
            secondaryButtonTitle: LocaleKeys.text_yes.tr(),
            action: () {
              context.pop();
            },
            onSecondaryAction: () async {
              await authService.logout();
              if (context.mounted) context.goNamed(AppRoute.splash);
            },
          );
        },
      ),
    ];
  }

  void getAppVersion() async {
    final version = await AppInfo.getVersion();
    state = state.copyWith(
      version: version,
    );
  }

  void handleResendEmail() async {
    state = state.copyWith(isLoadingResend: true);

    final result = await authService.resendEmail(
      email: user?.email ?? "",
    );

    result.when(
      success: (data) {
        state = state.copyWith(isLoadingResend: false);

        Snackbar.success(
          message: LocaleKeys.text_emailVerificationHasBeenResend.tr(),
          duration: 4,
        );
      },
      failure: (error, _) {
        state = state.copyWith(isLoadingResend: false);

        final message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);
      },
    );
  }
}

final mainAccountControllerProvider = StateNotifierProvider.family<
    MainAccountController, MainAccountState, BuildContext>(
  (ref, context) {
    return MainAccountController(
      context,
      ref.read(authenticationServiceProvider),
      ref.read(accountServiceProvider),
    );
  },
);
