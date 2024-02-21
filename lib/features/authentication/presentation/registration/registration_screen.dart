import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  final SignUpType type;
  final String? email;
  final String? phone;
  const RegistrationScreen({
    required this.type,
    this.email,
    this.phone,
    super.key,
  });

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  RegistrationController get controller => ref.read(
        registrationControllerProvider.notifier,
      );

  @override
  void initState() {
    safeRebuild(
      () {
        ref
            .read(
              registrationControllerProvider.notifier,
            )
            .init(
              widget.type,
              email: widget.email,
              phone: widget.phone,
            );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationControllerProvider);

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: LocaleKeys.text_registrationForm.tr(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: horizontalPadding,
              children: [
                Gap.h24,
                InputFormWidget(
                  controller: controller.firstNameController,
                  hintText: LocaleKeys.text_firstName.tr(),
                  hasIconState: false,
                  validator: ValidationBuilder(label: LocaleKeys.text_name.tr())
                      .build(),
                  label: LocaleKeys.text_firstName.tr(),
                  keyboardType: TextInputType.text,
                  hasBorderState: false,
                  onChanged: (_) => controller.clearError("firstName"),
                  error: state.errors['firstName'],
                ),
                Gap.h28,
                InputFormWidget(
                  controller: controller.lastNameController,
                  hintText: LocaleKeys.text_lastName.tr(),
                  hasIconState: false,
                  validator: ValidationBuilder(label: LocaleKeys.text_name.tr())
                      .build(),
                  label: LocaleKeys.text_lastName.tr(),
                  keyboardType: TextInputType.text,
                  hasBorderState: false,
                  onChanged: (_) => controller.clearError("lastName"),
                  error: state.errors['lastName'],
                ),
                Gap.h28,
                InputFormWidget(
                  isInputNumber: true,
                  label: LocaleKeys.text_phoneNumber.tr(),
                  controller: controller.phoneController,
                  hintText: LocaleKeys.text_phoneNumber.tr(),
                  hasIconState: false,
                  keyboardType: TextInputType.number,
                  hasBorderState: false,
                  validator: ValidationBuilder(
                    label: LocaleKeys.text_phoneNumber.tr(),
                  ).build(),
                  isActive: state.selectedSignUpMode != SignUpType.phone,
                  onChanged: (_) => controller.clearError("phone"),
                  error: state.errors['phone'],
                ),
                Gap.h28,
                InputFormWidget(
                  controller: controller.emailController,
                  hintText: LocaleKeys.text_email.tr(),
                  hasIconState: false,
                  validator:
                      ValidationBuilder(label: LocaleKeys.text_email.tr())
                          .build(),
                  label: LocaleKeys.text_email.tr(),
                  keyboardType: TextInputType.emailAddress,
                  hasBorderState: false,
                  isActive: state.selectedSignUpMode != SignUpType.email &&
                      state.selectedSignUpMode != SignUpType.social,
                  onChanged: (_) => controller.clearError("email"),
                  error: state.errors['email'],
                ),
                Gap.h28,
                InputFormWidget.password(
                  controller: controller.passwordController,
                  hintText: LocaleKeys.text_password.tr(),
                  label: LocaleKeys.text_password.tr(),
                  isObscure: state.isPasswordObscure,
                  validator:
                      ValidationBuilder(label: LocaleKeys.text_password.tr())
                          .build(),
                  onObscureTap: controller.toggleObscurePassword,
                  hasBorderState: false,
                  onChanged: (_) => controller.clearError("password"),
                  error: state.errors['password'],
                ),
                Gap.h28,
                InputFormWidget(
                  controller: controller.placeOfBirthController,
                  hintText: LocaleKeys.text_placeOfBirth.tr(),
                  hasIconState: false,
                  validator: ValidationBuilder(label: LocaleKeys.text_name.tr())
                      .build(),
                  label: LocaleKeys.text_placeOfBirth.tr(),
                  keyboardType: TextInputType.text,
                  hasBorderState: false,
                  onChanged: (_) => controller.clearError("placeOfBirth"),
                  error: state.errors['placeOfBirth'],
                ),
                Gap.h28,
                InputFormWidget.dropdown(
                  controller: controller.dateOfBirthController,
                  hintText: LocaleKeys.text_dateOfBirth.tr(),
                  hasIconState: false,
                  label: LocaleKeys.text_dateOfBirth.tr(),
                  suffixIcon: Assets.icons.line.calendarDays
                      .svg(colorFilter: BaseColor.neutral.shade50.filterSrcIn),
                  onBodyTap: () {
                    showDatePickerWidget(
                      context,
                      title: LocaleKeys.text_dateOfBirth.tr(),
                      savedDate: controller.dateOfBirth != ''
                          ? controller.dateOfBirth
                              .toFormattedDate(format: 'dd/MM/yyyy')
                          : null,
                      saveDate: controller.saveDate,
                    );
                  },
                  validator: null,
                  onChanged: (_) => controller.clearError("dateOfBirth"),
                  error: state.errors['dateOfBirth'],
                ),
                Gap.h28,
                SegmentedGenderSelect(
                  value: state.selectedGender,
                  onValueChanged: controller.changeGender,
                  error: state.errors['genderSerial'],
                ),
                Gap.h24,
                GestureDetector(
                  onTap: () {
                    controller.onAgreeChange(!state.isAgree);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckBoxWidget.primary(
                        value: state.isAgree,
                        onChanged: (val) {
                          controller.onAgreeChange(val);
                        },
                        size: CheckboxSize.small,
                      ),
                      Gap.w12,
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: LocaleKeys.text_byClickingRegisterButton
                                    .tr(),
                                style: TypographyTheme.textMRegular.toNeutral70,
                              ),
                              const TextSpan(
                                text: ' ',
                              ),
                              TextSpan(
                                text: LocaleKeys.text_termAndConditions.tr(),
                                style: TypographyTheme.textMBold
                                    .fontColor(BaseColor.primary3),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => context.pushNamed(
                                        AppRoute.termAndCondition,
                                        extra: const RouteParam(
                                          params: {
                                            RouteParamKey.code:
                                                TermAndConditionCode
                                                    .registration,
                                          },
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Gap.h48
              ],
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
                padding:
                    EdgeInsets.only(bottom: BaseSize.h28, top: BaseSize.h16),
                child: ButtonWidget.primary(
                  color: BaseColor.primary3,
                  overlayColor: BaseColor.white.withOpacity(.5),
                  isShrink: true,
                  isEnabled: state.isAgree,
                  isLoading: state.valid.isLoading,
                  text: LocaleKeys.text_register.tr(),
                  onTap: () => controller.onRegister(context),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
