import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class BottomSheetYourTurnToEnterWidget extends StatelessWidget {
  const BottomSheetYourTurnToEnterWidget({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    required this.queueNumber,
    required this.patientName,
    this.doctorName = "",
    this.methodName = "",
    this.medicalRecordNo = "",
    this.location="",
  });

  final SvgGenImage image;
  final String title;
  final String subTitle;
  final String queueNumber;
  final String patientName;
  final String doctorName;
  final String methodName;
  final String medicalRecordNo;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w20),
      child: Column(
        children: [
          image.svg(
            width: BaseSize.customWidth(110),
            height: BaseSize.customHeight(110),
          ),
          Gap.h20,
          Text(
            title,
            style: TypographyTheme.textLBold.toNeutral80,
          ),
          Gap.customGapHeight(10),
          Text(
            subTitle,
            textAlign: TextAlign.center,
            style: TypographyTheme.textMRegular.toNeutral60,
          ),
          queueNumber.isNotEmpty ?
          Gap.customGapHeight(37) : const SizedBox(),
          queueNumber.isNotEmpty ?
          Container(
            padding: EdgeInsets.symmetric(
              vertical: BaseSize.customHeight(16.5),
            ),
            decoration: const BoxDecoration(
              color: BaseColor.primary1,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    queueNumber,
                    style: TypographyTheme.textXLBold.copyWith(
                      fontSize: 36.sp,
                    ),
                  ),
                  Gap.customGapHeight(10),
                  Text(
                    LocaleKeys.text_yourQueueNumber.tr(),
                    style: TypographyTheme.textSRegular.toNeutral60,
                  ),
                ],
              ),
            ),
          ) : const SizedBox(),
          Gap.customGapHeight(37),
          _buildRow(
            LocaleKeys.text_patientName.tr(),
            patientName,
          ),
          Gap.h20,
          doctorName.isNotEmpty
              ? _buildRow(
                  LocaleKeys.text_doctor.tr(),
                  doctorName,
                )
              : const SizedBox(),
          doctorName.isNotEmpty ? Gap.h20 : const SizedBox(),
          methodName.isNotEmpty
              ? _buildRow(
                  LocaleKeys.text_method.tr(),
                  methodName,
                )
              : const SizedBox(),
          methodName.isNotEmpty ? Gap.h20 : const SizedBox(),
          location.isNotEmpty
              ? _buildRow(
            LocaleKeys.text_location.tr(),
            location,
          )
              : const SizedBox(),
          location.isNotEmpty? Gap.h20:const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildRow(String text, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text.toUpperCase(),
            style: TypographyTheme.textXSRegular.toNeutral60,
          ),
          Expanded(
            child: Text(
              value,
              style: TypographyTheme.textMSemiBold.toNeutral80,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );
}

Future<void> showYourTurnToEnterBottomSheet(
  BuildContext context, {
  required SvgGenImage image,
  required String title,
  required String subTitle,
   String queueNumber = "",
  required String patientName,
  String doctorName = "",
  String methodName = "",
  String medicalRecordNo = "",
      String location="",
  void Function()? onPressedOk,
}) async {
  await showCustomDialogWidget(
    context,
    title: "",
    hideLeftButton: true,
    isScrollControlled: true,
    btnRightText: LocaleKeys.text_ok.tr(),
    onTap: () {
      if (onPressedOk != null) {
        onPressedOk();
      }
      context.pop();
    },
    content: BottomSheetYourTurnToEnterWidget(
      image: image,
      title: title,
      subTitle: subTitle,
      queueNumber: queueNumber,
      patientName: patientName,
      doctorName: doctorName,
      methodName: methodName,
      medicalRecordNo: medicalRecordNo,
      location: location,
    ),
  );
}
