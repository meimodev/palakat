import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/domain.dart';

class PatientPickerCardWidget extends StatelessWidget {
  const PatientPickerCardWidget({
    super.key,
    this.onClick,
    this.patient,
    this.enable = true,
  });

  final Patient? patient;
  final void Function()? onClick;
  final bool enable;

  Widget _buildNoPatientSelectedLayout() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "${LocaleKeys.text_choose.tr()} ${LocaleKeys.text_patient.tr()}",
            style: TypographyTheme.textLSemiBold.toNeutral60,
          ),
        ),
        Assets.icons.line.chevronRight.svg(
          width: BaseSize.w24,
          height: BaseSize.h24,
        ),
      ],
    );
  }

  Widget _buildPatientSelectedLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                patient?.name ?? "",
                style: TypographyTheme.textLSemiBold.copyWith(
                  color: enable
                      ? BaseColor.neutral.shade80
                      : BaseColor.neutral.shade50,
                ),
              ),
            ),
            Assets.icons.line.chevronRight.svg(
              width: BaseSize.w24,
              height: BaseSize.h24,
              colorFilter: enable
                  ? BaseColor.neutral.shade80.filterSrcIn
                  : BaseColor.neutral.shade50.filterSrcIn,
            ),
          ],
        ),
        Gap.customGapHeight(10),
        Text(
          patient?.gender?.value.capitalizeSnakeCaseToTitle ?? "",
          style: TypographyTheme.textMRegular.copyWith(
            color:
                enable ? BaseColor.neutral.shade60 : BaseColor.neutral.shade50,
          ),
        ),
        Gap.h4,
        Text(
          patient?.dateOfBirth?.ddMmmmYyyy ?? "",
          style: TypographyTheme.textMRegular.copyWith(
            color:
                enable ? BaseColor.neutral.shade60 : BaseColor.neutral.shade50,
          ),
        ),
        Gap.h4,
        Text(
          patient?.phone ?? "",
          style: TypographyTheme.textMRegular.copyWith(
            color:
                enable ? BaseColor.neutral.shade60 : BaseColor.neutral.shade50,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.text_patient.tr(),
          style: TypographyTheme.textMRegular.toNeutral60,
        ),
        Gap.h12,
        InkWell(
          onTap: enable ? () => onClick!() : null,
          borderRadius: BorderRadius.circular(BaseSize.radiusLg),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: BaseSize.w16,
              vertical: BaseSize.h20,
            ),
            decoration: BoxDecoration(
              color: enable ? Colors.transparent : BaseColor.neutral.shade20,
              border: Border.all(
                color: BaseColor.neutral.shade20,
              ),
              borderRadius: BorderRadius.circular(BaseSize.radiusLg),
            ),
            child: Center(
              child: patient == null
                  ? _buildNoPatientSelectedLayout()
                  : _buildPatientSelectedLayout(),
            ),
          ),
        ),
        Gap.h20,
      ],
    );
  }
}
