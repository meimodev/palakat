import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientMedicalRecordFormWidget extends ConsumerWidget {
  const PatientMedicalRecordFormWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      patientFormControllerProvider.notifier,
    );
    final state = ref.watch(patientFormControllerProvider);

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
            child: Padding(
          padding: horizontalPadding,
          child: Form(
            key: controller.medicalFormKey,
            child: ListView(
              children: [
                Text(
                  LocaleKeys.text_haveYouEverBeenTreated.tr(),
                  style: TypographyTheme.textMRegular.toNeutral60,
                ),
                Gap.h20,
                SegmentedSelectWidget<YesOrNoAnswer>(
                  value: state.haveBeenTreated,
                  options: FormConstants.yesOrNoOptions,
                  onValueChanged: (val) {
                    controller.changeHaveBeenTreated(val);
                  },
                ),
                Gap.h32,
                if (state.haveBeenTreated == YesOrNoAnswer.yes) ...[
                  InputFormWidget(
                    controller: controller.mrnController,
                    hintText: LocaleKeys.text_medicalRecordNumber.tr(),
                    hasIconState: false,
                    label: LocaleKeys.text_medicalRecordNumber.tr(),
                    keyboardType: TextInputType.number,
                    hasBorderState: false,
                    onChanged: (_) => controller.clearError("mrn"),
                    error: state.errors['mrn'],
                  ),
                  Gap.h28,
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
                            ? controller.dateOfBirth
                                .toFormattedDate(format: 'dd/MM/yyyy')
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
                ],
              ],
            ),
          ),
        )),
        BottomActionWrapper(
          actionButton: ButtonWidget.primary(
            isEnabled: state.haveBeenTreated.isNotNull(),
            text: LocaleKeys.text_next.tr(),
            isLoading: state.valid.isLoading,
            onTap: () {
              if (state.haveBeenTreated == YesOrNoAnswer.yes) {
                controller.onPatientMRNSubmit();
              } else {
                controller.handleNextNewPatient();
              }
            },
          ),
        ),
      ],
    );
  }
}
