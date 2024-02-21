import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';

class DoctorPrescriptionWidget extends StatelessWidget {
  const DoctorPrescriptionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: BaseSize.h4),
      decoration: BoxDecoration(
        border: Border.all(color: BaseColor.neutral.shade20, width: 1),
        borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: InkWell(
          onTap: () {
            context
                .pushNamed(AppRoute.selfCheckInConsultationPrescriptionDetail);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.text_doctorPrescription.tr(),
                style: TypographyTheme.textLSemiBold.toNeutral60,
              ),
              Assets.icons.line.chevronRight.svg(
                height: BaseSize.h24,
                width: BaseSize.w24,
              )
            ],
          ),
        ),
      ),
    );
  }
}
