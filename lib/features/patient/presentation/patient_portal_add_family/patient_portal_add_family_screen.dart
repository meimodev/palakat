import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/patient/presentation/patient_portal_activation/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientPortalAddFamilyScreen extends ConsumerWidget {
  const PatientPortalAddFamilyScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(patientPortalAddFamilyController.notifier);
    final state = ref.watch(patientPortalAddFamilyController);

    return ScaffoldWidget(
      appBar: AppBarWidget(
        height: BaseSize.customHeight(70),
        title: LocaleKeys.text_addFamily.tr(),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap.customGapHeight(20),
                    InputFormWidget(
                      isImportant: true,
                      controller: controller.tecName,
                      hintText: LocaleKeys.text_name.tr(),
                      hasIconState: false,
                      label: LocaleKeys.text_name.tr(),
                      keyboardType: TextInputType.text,
                      hasBorderState: false,
                      onChanged: (_) => controller.checkProceed(),
                      validator:
                          ValidationBuilder(label: LocaleKeys.text_name.tr())
                              .required()
                              .build(),
                    ),
                    Gap.customGapHeight(30),
                    InputFormWidget(
                      isImportant: true,
                      controller: controller.tecDateOfBirth,
                      hintText: LocaleKeys.text_dateOfBirth.tr(),
                      hasIconState: false,
                      label: LocaleKeys.text_dateOfBirth.tr(),
                      keyboardType: TextInputType.text,
                      hasBorderState: false,
                      suffixIcon: Assets.icons.line.calendar.svg(
                        height: BaseSize.customHeight(18),
                        width: BaseSize.customWidth(18),
                        colorFilter: BaseColor.neutral.shade70.filterSrcIn,
                      ),
                      onChanged: (_) => controller.checkProceed(),
                      validator: ValidationBuilder(
                              label: LocaleKeys.text_dateOfBirth.tr())
                          .required()
                          .build(),
                    ),
                    Gap.customGapHeight(30),
                    SegmentedGenderSelect(
                      value: null,
                      onValueChanged: controller.setGender,
                    ),
                    Gap.customGapHeight(30),
                    InputCardPhotoWidget(
                      required: true,
                      title: LocaleKeys.text_identityCardPhoto.tr(),
                      onChangePhoto: (String? base64String) {
                        controller.setIdCardBase64(base64String ?? "");
                      },
                    ),
                    Gap.customGapHeight(30),
                    InputCardPhotoWidget(
                      required: true,
                      title: LocaleKeys.text_photoOfYouWithYourIDCard.tr(),
                      onChangePhoto: (String? base64String) {
                        controller.setIdCardAndPhotoBase64(base64String ?? "");
                      },
                    ),
                    Gap.customGapHeight(30),
                    TermsAndConditionDialogWidget(
                      onChangedCheck: (bool value) {
                        controller.setTNCAccept(value);
                      },
                      onTapTermsAndCondition: () {},
                    ),
                    Gap.customGapHeight(20),
                  ],
                ),
              ),
            ),
            BottomActionWrapper(
              actionButton: ButtonWidget.primary(
                text: LocaleKeys.text_submit.tr(),
                onTap: state.canProceed
                    ? () {
                        context.pop();
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
