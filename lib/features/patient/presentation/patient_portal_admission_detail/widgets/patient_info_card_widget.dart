import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class PatientInfoCardWidget extends StatelessWidget {
  const PatientInfoCardWidget({
    super.key,
    required this.patientName,
    required this.gender,
    required this.dateOfBirth,
  });

  final String patientName;
  final String gender;
  final String dateOfBirth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w16,
        vertical: BaseSize.h16,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: BaseColor.neutral.shade20,
        ),
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: BaseSize.customWidth(65),
            height: BaseSize.customWidth(65),
            decoration: BoxDecoration(
              color: BaseColor.neutral.shade20,
              borderRadius: BorderRadius.circular(BaseSize.radiusMd),
            ),
            child: Center(
              child: Assets.icons.fill.user.svg(
                  height: BaseSize.customHeight(37),
                  width: BaseSize.customWidth(37),
                  colorFilter: BaseColor.neutral.shade40.filterSrcIn),
            ),
          ),
          Gap.customGapWidth(15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patientName,
                style: TypographyTheme.textLSemiBold.toPrimary,
              ),
              Gap.h4,
              Text(
                gender,
                style: TypographyTheme.textSRegular.toNeutral60,
              ),
              Gap.h8,
              Text(
                dateOfBirth,
                style: TypographyTheme.textSRegular.toNeutral60,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
