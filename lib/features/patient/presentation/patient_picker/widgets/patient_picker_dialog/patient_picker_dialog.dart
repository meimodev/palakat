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

class PatientPickerDialog extends ConsumerStatefulWidget {
  const PatientPickerDialog({
    super.key,
    required this.onSave,
    this.value,
  });

  final void Function(Patient patient) onSave;
  final Patient? value;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PatientPickerDialogState();
}

class _PatientPickerDialogState extends ConsumerState<PatientPickerDialog> {
  PatientPickerDialogController get controller =>
      ref.read(patientPickerDialogControllerProvider(context).notifier);

  Widget _buildPatientItem({
    required void Function() onTap,
    required Patient patient,
    bool isSelected = false,
  }) {
    return CardWidget(
      onTap: onTap,
      borderColor: isSelected ? BaseColor.primary3 : BaseColor.neutral.shade20,
      backgroundColor: isSelected ? BaseColor.primary1 : BaseColor.white,
      content: [
        Text(
          patient.name,
          style: TypographyTheme.textLSemiBold.toNeutral80,
          overflow: TextOverflow.ellipsis,
        ),
        Gap.h8,
        Text(
          patient.dateOfBirth?.ddMmmmYyyy ?? "",
          style: TypographyTheme.textMRegular.toNeutral60,
        ),
        Gap.h4,
        Text(
          patient.phone,
          style: TypographyTheme.textMRegular.toNeutral60,
        ),
      ],
    );
  }

  Widget _buildAddNewPatient({required void Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.icons.line.userPlus.svg(
            width: BaseSize.w20,
            height: BaseSize.h20,
            colorFilter: BaseColor.primary3.filterSrcIn,
          ),
          Gap.customGapWidth(6),
          Text(
            LocaleKeys.text_addNewPatient.tr(),
            style: TypographyTheme.textLSemiBold.toPrimary,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    safeRebuild(() => controller.init(widget.value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patientPickerDialogControllerProvider(context));

    return SizedBox(
      height: MediaQuery.of(context).size.height * (65 / 100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
            child: Center(
              child: Assets.icons.fill.slidePanel.svg(),
            ),
          ),
          Gap.h12,
          Padding(
            padding: horizontalPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.text_patient.tr(),
                  style: TypographyTheme.bodySemiBold.toNeutral80,
                  textAlign: TextAlign.center,
                ),
                GestureDetector(
                  child: Assets.icons.line.times.svg(),
                  onTap: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          Gap.h20,
          Expanded(
            child: ListBuilderWidget(
              padding: horizontalPadding.add(EdgeInsets.symmetric(
                vertical: BaseSize.h12,
              )),
              data: state.data,
              onRefresh: controller.handleRefresh,
              itemBuilder: (context, index, item) {
                return _buildPatientItem(
                  patient: item,
                  onTap: () => controller.setSelectedPatient(item),
                  isSelected: state.selected == item,
                );
              },
              separatorBuilder: (context, index) => Gap.h16,
              isLoading: state.isLoading,
              postwidgets: [
                Gap.h20,
                _buildAddNewPatient(
                  onTap: () async {
                    await context.pushNamed(AppRoute.patientForm);

                    if (context.mounted) {
                      controller.loadData(withLoading: true);
                    }
                  },
                ),
                Gap.h12,
              ],
            ),
          ),
          Gap.h20,
          Padding(
            padding: horizontalPadding,
            child: ButtonWidget.primary(
              buttonSize: ButtonSize.medium,
              isEnabled: state.selected != null,
              text: LocaleKeys.text_submit.tr(),
              onTap: () {
                widget.onSave(state.selected!);
                Navigator.pop(context);
              },
            ),
          ),
          Gap.h16,
        ],
      ),
    );
  }
}
