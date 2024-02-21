import 'dart:io';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(signUpControllerProvider(context).notifier);
    final state = ref.watch(signUpControllerProvider(context));

    return ScaffoldWidget(
      type: ScaffoldType.auth,
      appBar: const AppBarWidget(
        backgroundColor: Colors.transparent,
        backIconColor: BaseColor.primary4,
      ),
      child: Padding(
        padding: horizontalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // physics: const BouncingScrollPhysics(),
          // padding: horizontalPadding,
          children: [
            Gap.h24,
            Text(LocaleKeys.text_hello.tr(),
                style:
                    TypographyTheme.heading2Bold.fontColor(BaseColor.primary4)),
            Gap.h4,
            Text(LocaleKeys.text_pleaseSignUpFirst.tr(),
                style: TypographyTheme.textLRegular
                    .fontColor(BaseColor.neutral.shade60)),
            Gap.h32,
            CustomSlidingSegmentedControl<SignUpType>(
              initialValue: state.selectedSignUpMode,
              children: {
                SignUpType.email: Text(LocaleKeys.text_email.tr(),
                    style: TypographyTheme.textLRegular.fontColor(
                        state.selectedSignUpMode == SignUpType.email
                            ? BaseColor.primary3
                            : BaseColor.neutral.shade60)),
                SignUpType.phone: Text(LocaleKeys.text_phone.tr(),
                    style: TypographyTheme.textLRegular.fontColor(
                        state.selectedSignUpMode == SignUpType.phone
                            ? BaseColor.primary3
                            : BaseColor.neutral.shade60)),
              },
              innerPadding: const EdgeInsets.all(6.0),
              fromMax: true,
              isStretch: true,
              decoration: BoxDecoration(
                color: BaseColor.neutral.shade10,
                borderRadius: BorderRadius.circular(8),
              ),
              thumbDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInToLinear,
              onValueChanged: (val) {
                controller.changeMode(val);
              },
            ),
            Gap.h36,
            if (state.selectedSignUpMode == SignUpType.email) ...[
              InputFormWidget(
                focusNode: controller.emailNode,
                controller: controller.emailController,
                hintText: LocaleKeys.text_email.tr(),
                hasIconState: false,
                validator: ValidationBuilder(label: LocaleKeys.text_email.tr())
                    .required()
                    .email()
                    .build(),
                label: LocaleKeys.text_email.tr(),
                keyboardType: TextInputType.emailAddress,
                hasBorderState: false,
                onChanged: (_) => controller.clearError("email"),
                error: state.errors['email'],
              ),
            ] else ...[
              InputFormWidget(
                focusNode: controller.numberNode,
                isInputNumber: true,
                label: LocaleKeys.text_phoneNumber.tr(),
                controller: controller.phoneController,
                hintText: LocaleKeys.text_phoneNumber.tr(),
                hasIconState: false,
                keyboardType: TextInputType.number,
                hasBorderState: false,
                validator: ValidationBuilder(
                  label: LocaleKeys.text_phoneNumber.tr(),
                ).required().build(),
                onChanged: (_) => controller.clearError("phone"),
                error: state.errors['phone'],
              ),
            ],
            Gap.h36,
            ButtonWidget.primary(
              color: BaseColor.primary3,
              overlayColor: BaseColor.white.withOpacity(.5),
              isLoading: state.isLoading,
              isEnabled: !state.isLoading,
              isShrink: true,
              text: LocaleKeys.text_signup.tr(),
              onTap: () => controller.onSignUp(context),
            ),
            Gap.h36,
            Row(children: <Widget>[
              Expanded(
                child: Container(
                    margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                    child: Divider(
                      color: BaseColor.neutral.shade40,
                      height: 36,
                    )),
              ),
              Text(LocaleKeys.text_orSignUpWith.tr(),
                  style: TextStyle(color: BaseColor.neutral.shade60)),
              Expanded(
                child: Container(
                    margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                    child: Divider(
                      color: BaseColor.neutral.shade40,
                      height: 36,
                    )),
              ),
            ]),
            Gap.h32,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  ButtonWidget.outlinedIcon(
                    icon: Assets.icons.fill.google.svg(width: 30),
                    outlineColor: BaseColor.neutral.shade20,
                    padding: EdgeInsets.symmetric(
                        vertical: BaseSize.h12, horizontal: BaseSize.w24),
                    onTap: controller.handleGoogleSignIn,
                  ),
                  ButtonWidget.outlinedIcon(
                    icon: Assets.icons.fill.facebookF.svg(
                        colorFilter: const Color(0XFF1977F3).filterSrcIn,
                        width: 30),
                    outlineColor: BaseColor.neutral.shade20,
                    padding: EdgeInsets.symmetric(
                        vertical: BaseSize.h12, horizontal: BaseSize.w24),
                    onTap: controller.handleFacebookSignIn,
                  ),
                  if (Platform.isIOS)
                    ButtonWidget.outlinedIcon(
                      icon: Assets.icons.fill.appleLogo.svg(width: 30),
                      outlineColor: BaseColor.neutral.shade20,
                      padding: EdgeInsets.symmetric(
                          vertical: BaseSize.h12, horizontal: BaseSize.w24),
                      onTap: controller.handleAppleSignIn,
                    ),
                ],
              ),
            ),
            Expanded(
              child: Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewPadding.bottom),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LocaleKeys.text_alreadyHaveAccount.tr(),
                          style: TextStyle(color: BaseColor.neutral.shade70),
                        ),
                        Gap.w4,
                        GestureDetector(
                          child: Text(LocaleKeys.text_login.tr(),
                              style: TypographyTheme.textLBold
                                  .fontColor(BaseColor.primary3)),
                          onTap: () {
                            context.pushNamed(AppRoute.login);
                          },
                        ),
                      ],
                    ),
                  )),
            ),
            Gap.h24
          ],
        ),
      ),
    );
  }
}
