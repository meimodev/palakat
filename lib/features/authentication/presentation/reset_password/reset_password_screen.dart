import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.userSerial,
    required this.token,
  });
  final String userSerial, token;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  ResetPasswordController get controller =>
      ref.read(resetPasswordControllerProvider(context).notifier);

  @override
  void initState() {
    safeRebuild(() => controller.init(widget.userSerial, widget.token));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetPasswordControllerProvider(context));

    return ScaffoldWidget(
      type: ScaffoldType.authGradient,
      appBar: AppBarWidget(
        backgroundColor: Colors.transparent,
        backIconColor: BaseColor.primary4,
        onLeadingPressed: () => context.goNamed(AppRoute.forgotPassword),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: horizontalPadding,
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Gap.h24,
                    Text(
                      LocaleKeys.text_resetPassword.tr(),
                      style: TypographyTheme.heading2Bold
                          .fontColor(BaseColor.primary4),
                    ),
                    Gap.h48,
                    InputFormWidget.password(
                      focusNode: controller.newPasswordNode,
                      controller: controller.newPasswordController,
                      hintText: LocaleKeys.text_newPassword.tr(),
                      label: LocaleKeys.text_newPassword.tr(),
                      isObscure: state.isNewPasswordObscure,
                      validator: ValidationBuilder(
                        label: LocaleKeys.text_newPassword.tr(),
                      ).required().build(),
                      onObscureTap: controller.toggleObscureNewPassword,
                      hasBorderState: false,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(
                          controller.confirmationPasswordNode,
                        );
                      },
                      onChanged: (_) => controller.clearError("password"),
                      error: state.errors['password'],
                    ),
                    Gap.h20,
                    InputFormWidget.password(
                      focusNode: controller.confirmationPasswordNode,
                      controller: controller.confirmationPasswordController,
                      hintText: LocaleKeys.text_confirmationNewPassword.tr(),
                      label: LocaleKeys.text_confirmationNewPassword.tr(),
                      isObscure: state.isConfirmationPasswordObscure,
                      validator: ValidationBuilder(
                        label: LocaleKeys.text_password.tr(),
                      ).same(controller.newPassword).build(),
                      onObscureTap:
                          controller.toggleObscureConfirmationPassword,
                      hasBorderState: false,
                    ),
                    Gap.h20,
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            child: Container(
              padding: horizontalPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(1),
                    offset: const Offset(-1, -2),
                    blurRadius: 9,
                    spreadRadius: -10,
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: BaseSize.h28,
                  top: BaseSize.h16,
                ),
                child: ButtonWidget.primary(
                  color: BaseColor.primary3,
                  overlayColor: BaseColor.white.withOpacity(.5),
                  isShrink: true,
                  isLoading: state.valid.isLoading,
                  text: LocaleKeys.text_submit.tr(),
                  onTap: () => controller.onSubmit(context),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
