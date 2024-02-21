import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/patient/domain/enum/enum.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'widgets/widgets.dart';

//Dummy data
const Duration _codeCoolDown = Duration(seconds: 10);
const _contact = "pri**********@gmail.com";
const _otpProvider = OtpProvider.whatsapp;

class PatientPortalForgotPinScreen extends ConsumerWidget {
  const PatientPortalForgotPinScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(patientPortalForgotPinController.notifier);
    final state = ref.watch(patientPortalForgotPinController);

    return ScaffoldWidget(
      type: ScaffoldType.authGradient,
      appBar: AppBarWidget(
        backgroundColor: Colors.transparent,
        height: BaseSize.customHeight(70),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ForgotPinHeaderLayoutWidget(
                    title: state.activateCreatePin
                        ? LocaleKeys.text_createPin.tr()
                        : LocaleKeys.text_forgotPin.tr(),
                    otpProvider: _otpProvider,
                    contact: _contact,
                    codeCoolDown: _codeCoolDown,
                    onFinishSendCodeTimeOut: () {},
                    onTapResetCode: () {},
                  ),
                  Form(
                    key: controller.formKey,
                    child: Column(
                      children: [
                        state.activateCreatePin
                            ? const SizedBox()
                            : ForgotPinLayoutWidget(
                                tecVerificationCode:
                                    controller.tecVerificationCode,
                              ),
                        state.activateCreatePin
                            ? CreateNewPinLayoutWidget(
                                tecPin: controller.tecPin,
                                tecPinConfirm: controller.tecPinConfirm,
                                onChangedPinAndPinConfirmText: () async {
                                  await Future.delayed(Duration.zero);
                                  controller.checkPinValidity();
                                },
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gap.customGapHeight(20),
          BottomActionWrapper(
            actionButton: ButtonWidget.primary(
              text: LocaleKeys.text_next.tr(),
              onTap: state.enableMainButton
                  ? () {
                      final valid = controller.formKey.currentState!.validate();
                      if (valid) {
                        if (state.activateCreatePin) {
                          context.pop();
                          return;
                        }
                        controller.toggleCreatePin();
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
