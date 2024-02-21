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
import 'package:halo_hermina/features/authentication/domain/login_type_enum.dart';
import 'package:halo_hermina/features/presentation.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.redirectBack ,
  });
  final bool? redirectBack;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  LoginController get controller =>
      ref.read(loginControllerProvider(context).notifier);

  @override
  void initState() {
    safeRebuild(() => controller.init(widget.redirectBack));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider(context));

    return ScaffoldWidget(
      type: ScaffoldType.auth,
      appBar: const AppBarWidget(
        backgroundColor: Colors.transparent,
        backIconColor: BaseColor.primary4,
      ),
      child: SizedBox(
        child: Padding(
          padding: horizontalPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // physics: const BouncingScrollPhysics(),
            // padding: horizontalPadding,
            children: [
              Gap.h16,
              Text(LocaleKeys.text_welcome.tr(),
                  style: TypographyTheme.heading2Bold
                      .fontColor(BaseColor.primary4)),
              Gap.h4,
              Text(LocaleKeys.text_pleaseLoginToYourAccount.tr(),
                  style: TypographyTheme.textLRegular
                      .fontColor(BaseColor.neutral.shade60)),
              Gap.h32,
              CustomSlidingSegmentedControl<LoginType>(
                initialValue: state.selectedLoginMode,
                children: {
                  LoginType.email: Text(
                    LoginType.email.labelKeyTranslation.tr(),
                    style: TypographyTheme.textLRegular.fontColor(
                        state.selectedLoginMode == LoginType.email
                            ? BaseColor.primary3
                            : BaseColor.neutral.shade60),
                  ),
                  LoginType.phone: Text(
                    LoginType.phone.labelKeyTranslation.tr(),
                    style: TypographyTheme.textLRegular.fontColor(
                        state.selectedLoginMode == LoginType.phone
                            ? BaseColor.primary3
                            : BaseColor.neutral.shade60),
                  ),
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
              Gap.h28,
              if (state.selectedLoginMode == LoginType.email) ...[
                InputFormWidget(
                  focusNode: controller.emailNode,
                  controller: controller.emailController,
                  hintText: LocaleKeys.text_email.tr(),
                  hasIconState: false,
                  validator:
                      ValidationBuilder(label: LocaleKeys.text_email.tr())
                          .required()
                          .build(),
                  label: LocaleKeys.text_email.tr(),
                  keyboardType: TextInputType.emailAddress,
                  hasBorderState: false,
                  onChanged: (_) => controller.clearError("username"),
                  error: state.errors['username'],
                ),
                Gap.h16,
                InputFormWidget.password(
                  focusNode: controller.passwordNode,
                  controller: controller.passwordController,
                  hintText: LocaleKeys.text_password.tr(),
                  label: LocaleKeys.text_password.tr(),
                  isObscure: state.isPasswordObscure,
                  validator:
                      ValidationBuilder(label: LocaleKeys.text_password.tr())
                          .required()
                          .build(),
                  onObscureTap: controller.toggleObscurePassword,
                  hasBorderState: false,
                  onChanged: (_) => controller.clearError("password"),
                  error: state.errors['password'],
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
              Gap.h16,
              GestureDetector(
                onTap: () {
                  context.pushNamed(AppRoute.forgotPassword);
                },
                child: Text(
                  LocaleKeys.text_forgotPassword.tr(),
                  textAlign: TextAlign.right,
                  style: TypographyTheme.textMRegular
                      .fontColor(BaseColor.primary3),
                ),
              ),
              Gap.h20,
              ButtonWidget.primary(
                color: BaseColor.primary3,
                overlayColor: BaseColor.white.withOpacity(.5),
                isShrink: true,
                isLoading: state.isLoading,
                text: LocaleKeys.text_login.tr(),
                onTap: () => controller.onLogin(context),
              ),
              Gap.h32,
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                        child: Divider(
                          color: BaseColor.neutral.shade40,
                          height: 36,
                        )),
                  ),
                  Text(LocaleKeys.text_orLoginWith.tr(),
                      style: TextStyle(color: BaseColor.neutral.shade60)),
                  Expanded(
                    child: Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                        child: Divider(
                          color: BaseColor.neutral.shade40,
                          height: 36,
                        )),
                  ),
                ],
              ),
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
                      onTap: () => controller.handleGoogleSignIn(),
                    ),
                    ButtonWidget.outlinedIcon(
                      icon: Assets.icons.fill.facebookF.svg(
                          colorFilter: const Color(0XFF1977F3).filterSrcIn,
                          width: 30),
                      outlineColor: BaseColor.neutral.shade20,
                      padding: EdgeInsets.symmetric(
                          vertical: BaseSize.h12, horizontal: BaseSize.w24),
                      onTap: () => controller.handleFacebookSignIn(),
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
                  alignment: AlignmentDirectional.bottomCenter, // <-- SEE HERE
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewPadding.bottom),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LocaleKeys.text_dontHaveAccount.tr(),
                          style: TextStyle(color: BaseColor.neutral.shade70),
                        ),
                        Gap.w4,
                        GestureDetector(
                          child: Text(LocaleKeys.text_signup.tr(),
                              style: TypographyTheme.textLBold
                                  .fontColor(BaseColor.primary3)),
                          onTap: () {
                            context.pushNamed(AppRoute.signup);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Gap.h24
            ],
          ),
        ),
      ),
    );
  }
}
