import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class PatientStatusTagChipWidget extends StatelessWidget {
  const PatientStatusTagChipWidget({
    super.key,
    required this.inpatient,
  });

  final bool inpatient;

  @override
  Widget build(BuildContext context) {
    final icon =
        inpatient ? Assets.icons.line.insomnia : Assets.icons.line.healthGraph;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w8,
        vertical: BaseSize.h8,
      ),
      decoration: BoxDecoration(
        color: BaseColor.primary1,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon.svg(
            width: BaseSize.customWidth(20),
            height: BaseSize.customWidth(20),
            colorFilter: BaseColor.secondary2.filterSrcIn,
          ),
          Gap.w4,
          Text(
            inpatient
                ? LocaleKeys.text_inpatient.tr()
                : LocaleKeys.text_outpatient.tr(),
            style: TypographyTheme.textSRegular.copyWith(
              color: BaseColor.secondary2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
