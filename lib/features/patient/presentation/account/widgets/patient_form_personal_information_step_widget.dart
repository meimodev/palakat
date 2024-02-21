import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientFormPersonalInformationStepWidget extends ConsumerWidget {
  const PatientFormPersonalInformationStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(patientFormControllerProvider.notifier);
    final state = ref.watch(patientFormControllerProvider);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
      InputFormWidget.dropdown(
        controller: controller.dateOfBirthController,
        hintText: LocaleKeys.text_dateOfBirth.tr(),
        hasIconState: false,
        label: LocaleKeys.text_dateOfBirth.tr(),
        onBodyTap: () {
          showDatePickerWidget(
            context,
            title: LocaleKeys.text_dateOfBirth.tr(),
            savedDate: controller.dateOfBirth != ''
                ? controller.dateOfBirth.toFormattedDate(format: 'dd/MM/yyyy')
                : null,
            saveDate: controller.saveDateOfBirth,
          );
        },
        validator: null,
        suffixIcon: Assets.icons.line.calendarDays.svg(
          colorFilter: BaseColor.neutral.shade50.filterSrcIn,
        ),
        error: state.errors['dateOfBirth'],
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
      InputFormWidget(
        controller: controller.emailController,
        hintText: LocaleKeys.text_email.tr(),
        hasIconState: false,
        validator: ValidationBuilder(label: LocaleKeys.text_email.tr()).build(),
        label: LocaleKeys.text_email.tr(),
        keyboardType: TextInputType.emailAddress,
        hasBorderState: false,
        onChanged: (_) => controller.clearError("email"),
        error: state.errors['email'],
      ),
      Gap.h32,
      InputFormWidget.dropdown(
        controller: controller.titleController,
        hintText: LocaleKeys.text_title.tr(),
        hasIconState: false,
        label: LocaleKeys.text_title.tr(),
        onBodyTap: () {
          showGeneralDataSelect(
            context,
            title: LocaleKeys.text_title.tr(),
            category: GeneralDataKey.title,
            selectedValue: state.selectedTitle,
            onSave: controller.onTitleChange,
          );
        },
        onChanged: (_) => controller.clearError("titleSerial"),
        error: state.errors['titleSerial'],
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
      InputFormWidget.dropdown(
        controller: controller.identityCardTypeController,
        hintText: LocaleKeys.text_identityCard.tr(),
        hasIconState: false,
        label: LocaleKeys.text_identityCard.tr(),
        onBodyTap: () {
          showSelectSingleWidget<IdentityType>(
            context,
            title: LocaleKeys.text_identityCard.tr(),
            selectedValue: state.selectedIdentityType,
            options: FormConstants.identityTypes,
            getValue: (type) => type.name,
            getLabel: (type) => type.label,
            onSave: (selected) {
              controller.onIdentityCardTypeChange(selected);
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
      Text(
        LocaleKeys.text_gender.tr(),
        style:
            TypographyTheme.textMRegular.fontColor(BaseColor.neutral.shade60),
      ),
      Gap.h12,
      SegmentedSelectWidget<String>(
        value: state.selectedGender,
        options: state.genderOptions,
        onValueChanged: (val) {
          controller.changeGender(val);
        },
      ),
      Gap.h12,
      if (state.errors['genderSerial'] != null)
        Text(
          state.errors['genderSerial'],
          style: TypographyTheme.textSRegular.fontColor(BaseColor.error),
        ),
      Gap.h32,
    ]);
  }
}
