import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

Future showPatientPhoneNumberSelect(
  BuildContext context, {
  required List<String> phones,
}) {
  return showCustomDialogWidget(
    title: '',
    context,
    hideButtons: true,
    isFlexible: true,
    onTap: () {},
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: BaseSize.w28),
          child: Text(
            LocaleKeys.text_selectPhoneNumber.tr(),
            textAlign: TextAlign.center,
            style: TypographyTheme.textXLBold.toNeutral80,
          ),
        ),
        Gap.h12,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: BaseSize.w28),
          child: Text(
            LocaleKeys
                .text_pleaseSelectOneOfYourNumberBelowToOpenYourMedicalRecordNumber
                .tr(),
            textAlign: TextAlign.center,
            style: TypographyTheme.textMRegular.toNeutral60,
          ),
        ),
        Gap.h24,
        _PatientFormPhoneNumberSelectWidget(
          phones: phones,
        ),
      ],
    ),
  );
}

class _PatientFormPhoneNumberSelectWidget extends ConsumerWidget {
  const _PatientFormPhoneNumberSelectWidget({this.phones = const []});

  final List<String> phones;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      patientFormControllerProvider.notifier,
    );
    final state = ref.watch(patientFormControllerProvider);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: BaseSize.w28),
          child: Column(children: [
            ...phones
                .map((e) => _createListItem(e, e, state.selectedPatientPhone,
                    controller.onPatientPhoneChange))
                .toList()
          ]),
        ),
        Gap.h24,
        BottomActionWrapper(
          actionButton: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ButtonWidget.primary(
                  text: LocaleKeys.text_select.tr(),
                  isShrink: true,
                  isEnabled: state.selectedPatientPhone.isNotEmpty,
                  onTap: () {
                    context.pop();
                    controller.sendOtp();
                  }),
              Gap.h12,
              ButtonWidget.outlined(
                text: LocaleKeys.text_visitFrontOffice.tr(),
                isShrink: true,
                isLoading: state.valid.isLoading,
                onTap: () {
                  context.pop();

                  state.patientType == PatientType.withNoMrn
                      ? controller.onPatientWithNoMRNSubmit(
                          isVisitFrontOffice: true)
                      : controller.onPatientMRNSubmit(isVisitFrontOffice: true);
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}

Widget _createListItem(
  String title,
  String value,
  String? selectedValue,
  Function(String?) onChange,
) {
  return ListTile(
    splashColor: BaseColor.primary2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: BaseSize.w4),
    minVerticalPadding: BaseSize.h4,
    leading: SizedBox(
        child: RadioWidget.primary(
      value: value,
      groupValue: selectedValue,
      onChanged: onChange,
    )),
    minLeadingWidth: 14,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.partiallyObscured,
          style: TypographyTheme.bodyRegular.toNeutral80,
        ),
      ],
    ),
    onTap: () {
      onChange(value);
    },
  );
}
