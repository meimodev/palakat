import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class ListItemPatientPortalListActiveAdmissionCard extends StatelessWidget {
  const ListItemPatientPortalListActiveAdmissionCard({
    super.key,
    this.id,
    this.roomNumber,
    required this.hospital,
    required this.admissionDate,
    required this.doctorName,
    required this.diagnose,
    this.onTap,
    this.disableBorder = false,
    this.removePadding = false,
    this.verticalDisplay = false,
  });

  final String? id;
  final String? roomNumber;
  final String hospital;
  final String admissionDate;
  final String doctorName;
  final String diagnose;

  final void Function()? onTap;

  final bool disableBorder;
  final bool removePadding;
  final bool verticalDisplay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: removePadding ? 0 : BaseSize.h24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          BaseSize.radiusLg,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: removePadding ? 0 : BaseSize.h16,
            vertical: removePadding ? 0 : BaseSize.w16,
          ),
          decoration: disableBorder
              ? null
              : BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: BaseColor.neutral.shade20,
                  ),
                  borderRadius: BorderRadius.circular(
                    BaseSize.radiusLg,
                  ),
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              id != null
                  ? Column(
                      children: [
                        Text(
                          id!,
                          style: TypographyTheme.textSSemiBold.toPrimary,
                          textAlign: TextAlign.center,
                        ),
                        Gap.h16,
                        DottedLine(
                          dashColor: BaseColor.neutral.shade30,
                        ),
                      ],
                    )
                  : const SizedBox(),
              removePadding ? const SizedBox() : Gap.h24,
              roomNumber == null
                  ? const SizedBox()
                  : Text(
                      LocaleKeys.text_roomNumber.tr().toUpperCase(),
                      style: TypographyTheme.textXSLight.toNeutral70,
                    ),
              roomNumber == null
                  ? const SizedBox()
                  : Text(
                      roomNumber!,
                      style: TypographyTheme.heading2Bold.copyWith(
                        fontSize: 30.sp,
                        color: BaseColor.neutral.shade70,
                      ),
                    ),
              Gap.customGapHeight(roomNumber == null ? 10 : 30),
              _buildAppointmentInfoLayout(verticalDisplay: verticalDisplay),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentInfoLayout({
    required bool verticalDisplay,
  }) {
    return Column(
      children: [
        Flex(
          direction: verticalDisplay ? Axis.vertical : Axis.horizontal,
          children: [
            Flexible(
              flex: verticalDisplay ? 0 : 1,
              child: _buildItem(
                icon: Assets.icons.line.hospital3,
                title: LocaleKeys.text_hospital.tr(),
                text: hospital,
              ),
            ),
            verticalDisplay ? Gap.h24 :Gap.w24,
            Flexible(
              flex: verticalDisplay ? 0 : 1,
              child: _buildItem(
                icon: Assets.icons.line.stethoscope,
                title: LocaleKeys.text_doctor.tr(),
                text: doctorName,
              ),
            ),
          ],
        ),
        Gap.h24 ,
        Flex(
          direction: verticalDisplay ? Axis.vertical : Axis.horizontal,
          children: [
            Flexible(
              flex: verticalDisplay ? 0 : 1,
              child: _buildItem(
                icon: Assets.icons.line.calendarDays,
                title: LocaleKeys.text_admissionDate.tr(),
                text: admissionDate,
              ),
            ),
            verticalDisplay ? Gap.h24 :Gap.w24,
            Flexible(
              flex: verticalDisplay ? 0 : 1,
              child: _buildItem(
                icon: Assets.icons.line.medicalFile,
                title: LocaleKeys.text_diagnose.tr(),
                text: diagnose,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItem({
    required SvgGenImage icon,
    required String text,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.customWidth(4),
            vertical: BaseSize.customWidth(4),
          ),
          width: BaseSize.customWidth(24),
          height: BaseSize.customWidth(24),
          decoration: const BoxDecoration(
            color: BaseColor.primary3,
            shape: BoxShape.circle,
          ),
          child: icon.svg(
            colorFilter: Colors.white.filterSrcIn,
          ),
        ),
        Gap.w8,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: TypographyTheme.textXSLight.toNeutral70,
              ),
              Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TypographyTheme.textSRegular.toNeutral70,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
