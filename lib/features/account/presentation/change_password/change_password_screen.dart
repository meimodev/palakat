import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  ChangePasswordController get controller =>
      ref.read(changePasswordControllerProvider(context).notifier);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePasswordControllerProvider(context));

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: LocaleKeys.text_changePassword.tr(),
      ),
      child: Padding(
        padding: horizontalPadding.add(
          EdgeInsets.symmetric(vertical: BaseSize.h24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!controller.isEmptyPassword)
                      InputFormWidget.password(
                        focusNode: controller.oldPasswordNode,
                        controller: controller.oldPasswordController,
                        hintText: LocaleKeys.text_oldPassword.tr(),
                        label: LocaleKeys.text_oldPassword.tr(),
                        isObscure: state.isOldPasswordObscure,
                        onObscureTap: controller.toggleObscureOldPassword,
                        hasBorderState: false,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(
                            controller.newPasswordNode,
                          );
                        },
                        onChanged: (_) => controller.clearError("oldPassword"),
                        error: state.errors['oldPassword'],
                      ),
                    Gap.h20,
                    InputFormWidget.password(
                      focusNode: controller.newPasswordNode,
                      controller: controller.newPasswordController,
                      hintText: LocaleKeys.text_newPassword.tr(),
                      label: LocaleKeys.text_newPassword.tr(),
                      isObscure: state.isNewPasswordObscure,
                      onObscureTap: controller.toggleObscureNewPassword,
                      hasBorderState: false,
                      textInputAction: TextInputAction.next,
                      validator: ValidationBuilder(
                        label: LocaleKeys.text_newPassword.tr(),
                      ).required().build(),
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(
                          controller.confirmationPasswordNode,
                        );
                      },
                      onChanged: (_) => controller.clearError("newPassword"),
                      error: state.errors['newPassword'],
                    ),
                    Gap.h20,
                    InputFormWidget.password(
                      focusNode: controller.confirmationPasswordNode,
                      controller: controller.confirmationPasswordController,
                      hintText: LocaleKeys.text_confirmationNewPassword.tr(),
                      label: LocaleKeys.text_confirmationNewPassword.tr(),
                      isObscure: state.isConfirmationPasswordObscure,
                      textInputAction: TextInputAction.done,
                      validator: ValidationBuilder(
                        label: LocaleKeys.text_newPassword.tr(),
                      ).same(controller.newPassword).build(),
                      onChanged: (_) => controller.clearAllError(),
                      onObscureTap:
                          controller.toggleObscureConfirmationPassword,
                      hasBorderState: false,
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ButtonWidget.outlined(
                    isEnabled: !state.valid.isLoading,
                    text: LocaleKeys.text_cancel.tr(),
                    isShrink: true,
                    onTap: () => context.pop(),
                  ),
                ),
                Gap.w16,
                Expanded(
                  child: ButtonWidget.primary(
                    text: LocaleKeys.text_submit.tr(),
                    isLoading: state.valid.isLoading,
                    isShrink: true,
                    onTap: () => controller.onSubmit(),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
