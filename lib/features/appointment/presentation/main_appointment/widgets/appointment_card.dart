import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

enum AppointmentCardType { active, past }

class AppointmentCard extends ConsumerWidget {
  const AppointmentCard.upcoming({
    Key? key,
    required this.name,
    this.number,
    required this.date,
    required this.hospital,
    required this.doctor,
    required this.specialist,
    this.alertMessage,
    this.onTap,
    this.onCancel,
    this.onReschedule,
    this.onManage,
  })  : type = AppointmentCardType.active,
        super(key: key);

  const AppointmentCard.past({
    Key? key,
    required this.name,
    required this.date,
    required this.hospital,
    required this.doctor,
    required this.specialist,
    this.onTap,
  })  : type = AppointmentCardType.past,
        number = null,
        onCancel = null,
        onReschedule = null,
        alertMessage = null,
        onManage = null,
        super(key: key);

  final String name;
  final String date;
  final String hospital;
  final String doctor;
  final String specialist;
  final int? number;
  final String? alertMessage;
  final AppointmentCardType type;
  final void Function()? onTap;
  final void Function()? onCancel;
  final void Function()? onReschedule;
  final void Function()? onManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CardWidget(
      onTap: onTap,
      content: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    name,
                    style: type == AppointmentCardType.active
                        ? TypographyTheme.textSSemiBold.toNeutral70
                        : TypographyTheme.textLSemiBold.toNeutral70,
                  ),
                  if (type == AppointmentCardType.active && number != null) ...[
                    Gap.customGapHeight(6),
                    Text(
                      number.toString(),
                      style: TextStyle(
                        fontSize: 30.sp,
                        color: BaseColor.neutral.shade70,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                  if (type == AppointmentCardType.past) ...[
                    Gap.customGapHeight(6),
                    Text(
                      date,
                      style: TypographyTheme.textMSemiBold.toNeutral60,
                    ),
                  ],
                  Gap.customGapHeight(6),
                  Text(
                    hospital,
                    style: TypographyTheme.textSRegular
                        .fontColor(BaseColor.neutral.shade60),
                  ),
                  Gap.customGapHeight(4),
                  Text(
                    doctor,
                    style: TypographyTheme.textSRegular
                        .fontColor(BaseColor.neutral.shade60),
                  ),
                  Gap.customGapHeight(4),
                  Text(
                    specialist,
                    style: TypographyTheme.textSRegular
                        .fontColor(BaseColor.neutral.shade50),
                  ),
                ],
              ),
            ),
            Gap.w12,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (type == AppointmentCardType.active) ...[
                  Text(
                    date,
                    style: TypographyTheme.textSRegular.toNeutral50,
                  ),
                  Gap.h4,
                ],
                Container(
                  decoration: BoxDecoration(
                    color: BaseColor.primary1,
                    borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  ),
                  padding: EdgeInsets.all(BaseSize.customWidth(6)),
                  child: Row(
                    children: [
                      Assets.icons.line.medicalDoctor.svg(
                        height: BaseSize.customWidth(18),
                        width: BaseSize.customWidth(18),
                      ),
                      Gap.w4,
                      Text(
                        LocaleKeys.text_doctor.tr(),
                        style: TypographyTheme.textSRegular
                            .fontColor(BaseColor.secondary2),
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
        if (alertMessage.isNotNull()) ...[
          Gap.h12,
          InlineAlertWidget(message: alertMessage!)
        ],
        if (type == AppointmentCardType.active) ...[
          Gap.h12,
          onManage.isNotNull()
              ? ButtonWidget.primary(
                  text: LocaleKeys.text_manageAppointment.tr(),
                  onTap: onManage,
                  isShrink: true,
                  buttonSize: ButtonSize.small,
                )
              : Row(
                  children: [
                    if (onCancel != null)
                      Expanded(
                        child: ButtonWidget.outlined(
                          text: LocaleKeys.text_cancel.tr(),
                          onTap: onCancel,
                          isShrink: true,
                          buttonSize: ButtonSize.small,
                        ),
                      ),
                    if (onCancel != null && onReschedule != null) Gap.w12,
                    if (onReschedule != null)
                      Expanded(
                        child: onCancel == null
                            ? ButtonWidget.primary(
                                text: LocaleKeys.text_reschedule.tr(),
                                onTap: onReschedule,
                                isShrink: true,
                                buttonSize: ButtonSize.small,
                              )
                            : ButtonWidget.outlined(
                                text: LocaleKeys.text_reschedule.tr(),
                                onTap: onReschedule,
                                isShrink: true,
                                buttonSize: ButtonSize.small,
                              ),
                      )
                  ],
                )
        ]
      ],
    );
  }
}
