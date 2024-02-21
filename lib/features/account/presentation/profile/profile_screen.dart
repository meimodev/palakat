import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ProfileController get controller =>
      ref.read(profileControllerProvider(context).notifier);

  @override
  void initState() {
    controller.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider(context));

    return ScaffoldWidget(
      resizeToAvoidBottomInset: false,
      appBar: AppBarWidget(
        title: LocaleKeys.text_myProfile.tr(),
      ),
      child: LoadingWrapper(
        value: state.isLoading,
        child: Padding(
          padding: horizontalPadding.add(
            EdgeInsets.symmetric(vertical: BaseSize.h20),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: BaseSize.h16),
                  children: [
                    InputFormWidget(
                      controller: controller.firstNameController,
                      hintText: LocaleKeys.text_firstName.tr(),
                      hasIconState: false,
                      label: LocaleKeys.text_firstName.tr(),
                      keyboardType: TextInputType.text,
                      hasBorderState: false,
                      onChanged: (_) => controller.clearError("firstName"),
                      error: state.errors['firstName'],
                    ),
                    Gap.h32,
                    InputFormWidget(
                      controller: controller.lastNameController,
                      hintText: LocaleKeys.text_lastName.tr(),
                      hasIconState: false,
                      label: LocaleKeys.text_lastName.tr(),
                      keyboardType: TextInputType.text,
                      hasBorderState: false,
                      onChanged: (_) => controller.clearError("lastName"),
                      error: state.errors['lastName'],
                    ),
                    Gap.h32,
                    InputFormWidget(
                      controller: controller.emailController,
                      hintText: LocaleKeys.text_email.tr(),
                      hasIconState: false,
                      validator: ValidationBuilder(
                        label: LocaleKeys.text_email.tr(),
                      ).email().build(),
                      label: LocaleKeys.text_email.tr(),
                      keyboardType: TextInputType.emailAddress,
                      hasBorderState: false,
                      onChanged: (_) => controller.clearError("email"),
                      error: state.errors['email'],
                    ),
                    Gap.h32,
                    InputFormWidget(
                      isInputNumber: true,
                      label: LocaleKeys.text_phoneNumber.tr(),
                      controller: controller.phoneController,
                      hintText: LocaleKeys.text_phoneNumber.tr(),
                      hasIconState: false,
                      keyboardType: TextInputType.number,
                      hasBorderState: false,
                      onChanged: (_) => controller.clearError("phone"),
                      error: state.errors['phone'],
                    ),
                    Gap.h32,
                    InputFormWidget.dropdown(
                      controller: controller.identityCardController,
                      hintText: LocaleKeys.text_identityCard.tr(),
                      hasIconState: true,
                      label: LocaleKeys.text_identityCard.tr(),
                      onBodyTap: () {
                        showSelectSingleWidget<IdentityType>(
                          context,
                          title: LocaleKeys.text_identityCard.tr(),
                          selectedValue: state.selectedIdentity,
                          options: FormConstants.identityTypes,
                          getValue: (type) => type.name,
                          getLabel: (type) => type.label,
                          onSave: (selected) {
                            controller.saveIdentity(selected);
                          },
                        );
                      },
                      onChanged: (_) => controller.clearError("identityType"),
                      error: state.errors['identityType'],
                    ),
                    Gap.h32,
                    InputFormWidget(
                      controller: controller.identityCardNumberController,
                      hintText: LocaleKeys.text_identityCardNumber.tr(),
                      hasIconState: false,
                      label: LocaleKeys.text_identityCardNumber.tr(),
                      keyboardType: TextInputType.number,
                      hasBorderState: false,
                      onChanged: (_) => controller.clearError("identityNumber"),
                      error: state.errors['identityNumber'],
                    ),
                    Gap.h32,
                    InputFormWidget.dropdown(
                      controller: controller.dateOfBirthController,
                      hintText: LocaleKeys.text_dateOfBirth.tr(),
                      hasIconState: false,
                      label: LocaleKeys.text_dateOfBirth.tr(),
                      onBodyTap: () {
                        showDatePickerWidget(
                          context,
                          title: LocaleKeys.text_dateOfBirth.tr(),
                          onDateTimeChanged: controller.selectDate,
                          savedDate: state.savedDate,
                          saveDate: controller.saveDate,
                        );
                      },
                      suffixIcon: Assets.icons.line.calendarDays.svg(
                        colorFilter: BaseColor.neutral.shade50.filterSrcIn,
                      ),
                      onChanged: (_) => controller.clearError("dateOfBirth"),
                      error: state.errors['dateOfBirth'],
                    ),
                    Gap.h32,
                    InputFormWidget(
                      controller: controller.placeOfBirthController,
                      hintText: LocaleKeys.text_placeOfBirth.tr(),
                      hasIconState: false,
                      label: LocaleKeys.text_placeOfBirth.tr(),
                      keyboardType: TextInputType.text,
                      hasBorderState: false,
                      onChanged: (_) => controller.clearError("placeOfBirth"),
                      error: state.errors['placeOfBirth'],
                    ),
                    Gap.h32,
                    SegmentedGenderSelect(
                      value: state.selectedGender,
                      onValueChanged: controller.changeGender,
                      error: state.errors['genderSerial'],
                    ),
                  ],
                ),
              ),
              Gap.h12,
              Row(
                children: [
                  Expanded(
                    child: ButtonWidget.outlined(
                      text: LocaleKeys.text_cancel.tr(),
                      isShrink: true,
                      isEnabled: !state.valid.isLoading,
                      onTap: () => context.pop(),
                    ),
                  ),
                  Gap.w16,
                  Expanded(
                    child: ButtonWidget.primary(
                      text: LocaleKeys.text_save.tr(),
                      isShrink: true,
                      isLoading: state.valid.isLoading,
                      onTap: () => controller.onSubmit(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
