import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

Future<void> showSelfCheckinDialogWidget({
  required BuildContext context,
  required void Function() onPressedConfirm,
  required String queueNumber,
  required String patientName,
  required String doctorName,
  required String medicalRecordNumber,
}) async {
  await showGeneralDialogWidget(
    context,
    image: Assets.images.check.image(
      width: BaseSize.customWidth(100),
      height: BaseSize.customHeight(100),
    ),
    title: LocaleKeys.text_selfCheckInHasSuccessful.tr(),
    subtitle:
        LocaleKeys.text_meetTheNurseToNurseAssessmentNearTheDoctorsOffice.tr(),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap.customGapHeight(37),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: BaseSize.customWidth(16),
          ),
          decoration: BoxDecoration(
            color: BaseColor.primary1,
            borderRadius: BorderRadius.circular(BaseSize.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                queueNumber,
                style: TypographyTheme.textSRegular.copyWith(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                LocaleKeys.text_yourQueueNumber.tr(),
                style: TypographyTheme.textSRegular.toNeutral60,
              ),
            ],
          ),
        ),
        Gap.customGapHeight(37),
        _buildRow(
          title: 'Patient Name',
          text: patientName,
        ),
        _buildRow(
          title: 'Doctor',
          text: doctorName,
        ),
        _buildRow(
          title: 'Medical Record Number',
          text: medicalRecordNumber,
        ),
      ],
    ),
    primaryButtonTitle: LocaleKeys.text_trackQueue.tr(),
    action: () {
      context.pop();
      onPressedConfirm();
    },
  );
}

Widget _buildRow({
  required String title,
  required String text,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: BaseSize.h20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: TypographyTheme.textXSRegular,
        ),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TypographyTheme.textSSemiBold,
          ),
        ),
      ],
    ),
  );
}

Future<void> showItsSelfCheckInTimeDialogWidget({
  required BuildContext context,
  required void Function() onPressedConfirm,
}) async {
  await showGeneralDialogWidget(
    context,
    image: Assets.icons.fill.mobilePhone1.svg(
      width: BaseSize.customWidth(110),
      height: BaseSize.customHeight(110),
    ),
    title: "${LocaleKeys.text_itsSelfCheckinTime.tr()}!",
    subtitle: LocaleKeys.text_dontForgetToDoYourSelfCheckIn.tr(),
    primaryButtonTitle: LocaleKeys.text_ok.tr(),
    content: Gap.h40,
    action: () {
      context.pop();
      onPressedConfirm();
    },
  );
}
