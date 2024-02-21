import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientFormAdditionalInformationStepWidget extends ConsumerWidget {
  const PatientFormAdditionalInformationStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(patientFormControllerProvider.notifier);
    final state = ref.watch(patientFormControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputFormWidget.dropdown(
          controller: controller.religionController,
          hintText: LocaleKeys.text_religion.tr(),
          hasIconState: false,
          label: LocaleKeys.text_religion.tr(),
          onBodyTap: () {
            showGeneralDataSelect(context,
                title: LocaleKeys.text_religion.tr(),
                category: GeneralDataKey.religion,
                selectedValue: state.selectedReligion,
                onSave: controller.onReligionChange,
                heightPercentage: 50,
                showSearch: false);
          },
          onChanged: (_) => controller.clearError("religionSerial"),
          error: state.errors['religionSerial'],
        ),
        Gap.h32,
        InputFormWidget.dropdown(
          controller: controller.maritalController,
          hintText: LocaleKeys.text_maritalStatus.tr(),
          hasIconState: false,
          label: LocaleKeys.text_maritalStatus.tr(),
          onBodyTap: () {
            showGeneralDataSelect(context,
                title: LocaleKeys.text_maritalStatus.tr(),
                category: GeneralDataKey.marital,
                selectedValue: state.selectedMarital,
                onSave: controller.onMaritalChange,
                heightPercentage: 40,
                showSearch: false);
          },
          onChanged: (_) => controller.clearError("maritalSerial"),
          error: state.errors['maritalSerial'],
        ),
        Gap.h32,
        InputFormWidget.dropdown(
          controller: controller.educationController,
          hintText: LocaleKeys.text_education.tr(),
          hasIconState: false,
          label: LocaleKeys.text_education.tr(),
          onBodyTap: () {
            showGeneralDataSelect(context,
                title: LocaleKeys.text_education.tr(),
                category: GeneralDataKey.education,
                selectedValue: state.selectedEducation,
                onSave: controller.onEducationChange);
          },
          onChanged: (_) => controller.clearError("educationSerial"),
          error: state.errors['educationSerial'],
        ),
        Gap.h32,
        InputFormWidget.dropdown(
          controller: controller.occupationController,
          hintText: LocaleKeys.text_jobTitle.tr(),
          hasIconState: false,
          label: LocaleKeys.text_jobTitle.tr(),
          onBodyTap: () {
            showGeneralDataSelect(context,
                title: LocaleKeys.text_jobTitle.tr(),
                category: GeneralDataKey.occupation,
                selectedValue: state.selectedOccupation,
                onSave: controller.onOccupationChange);
          },
          onChanged: (_) => controller.clearError("occupationSerial"),
          error: state.errors['occupationSerial'],
        ),
        Gap.h32,
        InputFormWidget.dropdown(
          controller: controller.citizenshipController,
          hintText: LocaleKeys.text_citizenship.tr(),
          hasIconState: false,
          label: LocaleKeys.text_citizenship.tr(),
          onBodyTap: () {
            showGeneralDataSelect(context,
                title: LocaleKeys.text_citizenship.tr(),
                category: GeneralDataKey.country,
                selectedValue: state.selectedCitizenship,
                onSave: controller.onCitizenshipChange);
          },
          onChanged: (_) => controller.clearError("citizenshipSerial"),
          error: state.errors['citizenshipSerial'],
        ),
        Gap.h32,
        InputFormWidget.dropdown(
          controller: controller.ethnicController,
          hintText: LocaleKeys.text_ethnicity.tr(),
          hasIconState: false,
          label: LocaleKeys.text_ethnicity.tr(),
          onBodyTap: () {
            showGeneralDataSelect(context,
                title: LocaleKeys.text_ethnicity.tr(),
                category: GeneralDataKey.ethnic,
                selectedValue: state.selectedEthnic,
                onSave: controller.onEthnicChange);
          },
          onChanged: (_) => controller.clearError("ethnicSerial"),
          error: state.errors['ethnicSerial'],
        ),
        Gap.h32,
        ImageUpload(
          title: LocaleKeys.text_identityCardPhoto.tr(),
          onChangeImage: controller.onPhotoChange,
          value: state.selectedPhoto,
          configCode: MediaConfigCodeKey.private,
          onRemoveImage: controller.onPhotoRemove,
          required: true,
          formError: state.errors['identityCardSerial'],
        ),
        Gap.h32,
        ImageUpload(
          title: LocaleKeys.text_photoOfYouWithYourIDCard.tr(),
          onChangeImage: controller.onPhotoWithIdCardChange,
          value: state.selectedPhotoWithIdCard,
          configCode: MediaConfigCodeKey.private,
          onRemoveImage: controller.onPhotoWithIdCardRemove,
          required: true,
          formError: state.errors['photoSerial'],
        ),
      ],
    );
  }
}
