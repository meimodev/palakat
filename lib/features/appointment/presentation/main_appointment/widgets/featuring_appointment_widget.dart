import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class FeaturingAppointmentWidget extends StatelessWidget {
  final String variety;
  final String name;
  final dynamic number;
  final String date;
  final String doctorName;
  final String? journey;
  final String hospital;
  final String? alertMessage;
  final AlertType alertType;
  final Widget? action;

  const FeaturingAppointmentWidget({
    super.key,
    required this.variety,
    required this.name,
    this.number,
    required this.date,
    required this.doctorName,
    this.journey,
    required this.hospital,
    this.action,
    this.alertMessage,
    this.alertType = AlertType.warning,
  });

  Widget _createInfoItem(String title, String subtitle, SvgGenImage icon) {
    return Row(children: [
      Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(60), color: BaseColor.primary3),
        child: icon.svg(
          colorFilter: Colors.white.filterSrcIn,
          width: 14,
          height: 14,
          fit: BoxFit.scaleDown,
        ),
      ),
      Gap.w12,
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TypographyTheme.textXSLight.toNeutral70,
            ),
            Gap.h4,
            Text(
              subtitle,
              style: TypographyTheme.textSRegular.toNeutral70,
            )
          ],
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      backgroundColor: BaseColor.white,
      content: [
        Text(
          variety,
          textAlign: TextAlign.center,
          style: TypographyTheme.textSSemiBold.toPrimary,
        ),
        Gap.h16,
        DashLineSeparator(
          color: BaseColor.neutral.shade30,
        ),
        Gap.h16,
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      name,
                      style: TypographyTheme.textSSemiBold.toNeutral70,
                    ),
                    Text(
                      number != null ? number.toString() : "--",
                      style: TypographyTheme.textSRegular.toNeutral70.copyWith(
                        fontSize: 48.sp,
                      ),
                    ),
                  ],
                )),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        date,
                        textAlign: TextAlign.end,
                        style: TypographyTheme.textSRegular.toNeutral50,
                      ),
                      Gap.customGapHeight(20),
                      _createInfoItem(
                        LocaleKeys.text_hospital.tr().toUpperCase(),
                        hospital,
                        Assets.icons.line.hospital3,
                      ),
                    ],
                  ),
                )
              ],
            ),
            Gap.h8,
            Row(
              children: [
                Expanded(
                  child: _createInfoItem(
                      LocaleKeys.text_doctor.tr().toUpperCase(),
                      doctorName,
                      Assets.icons.line.stethoscope),
                ),
                Expanded(
                  child: _createInfoItem(
                    LocaleKeys.text_journey.tr().toUpperCase(),
                    journey ?? '-',
                    Assets.icons.line.journey,
                  ),
                ),
              ],
            ),
            if (alertMessage?.isNotEmpty ?? false) ...[
              Gap.h16,
              InlineAlertWidget(
                message: alertMessage!,
                type: alertType,
              ),
            ],
            Gap.h12,
            if (action.isNotNull()) action!
          ],
        )
      ],
    );
  }
}
