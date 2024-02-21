import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

import 'widgets/widgets.dart';

class PatientPortalScreen extends ConsumerStatefulWidget {
  const PatientPortalScreen({super.key});

  @override
  ConsumerState createState() => _PatientPortalScreenState();
}

class _PatientPortalScreenState extends ConsumerState<PatientPortalScreen> {
  get state => ref.watch(mainPatientPortalController);

  MainPatientPortalController get controller =>
      ref.watch(mainPatientPortalController.notifier);

  @override
  void initState() {
    super.initState();
    safeRebuild(
      () => controller.init(openLoginScreen),
    );
  }

  Future<Object?> openLoginScreen() => context.pushNamed(
        AppRoute.login,
        extra: const RouteParam(
          params: {
            RouteParamKey.redirectBack: true,
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      type: ScaffoldType.authGradient,
      useSafeArea: false,
      child: LoadingWrapper(
        value: state.loading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!controller.loggedIn)
              Expanded(
                child: NotLoggedInLayoutWidget(
                  onTapLoginButton: () {
                    controller.onPressedLogin(openLoginScreen);
                  },
                ),
              )
            else if (state.authorized)
              const Expanded(
                child: AuthorizedLayoutWidget(
                  patientName: 'Pricillia Pamela',
                ),
              )
            else
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: BaseSize.w24),
                  child: UnauthorizedLayoutWidget(
                    patientPortalStatus: state.patientPortalStatus,
                    tecPin: controller.inputPinTextController,
                    loginByBiometric: () => controller.loginByBiometric(),
                    onChangedPin: (String value) {},
                    onCompletedPin: (String value) {},
                    onPressedSubmitChooseOption: (value) {},
                    onPressedActivatePatientPortal: () async {
                      final result = await context
                          .pushNamed(AppRoute.patientPortalActivation);

                      if (result != null) {
                        await controller.checkPatientPortalStatus();
                      }
                    },
                    onCreatingNewPin: () async {},
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

