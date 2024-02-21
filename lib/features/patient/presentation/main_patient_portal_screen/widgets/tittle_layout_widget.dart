import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class TitleLayoutWidget extends StatelessWidget {
  const TitleLayoutWidget({
    super.key,
    required this.authorized,
    this.bottomPadding = false,
  });

  final bool authorized;
  final bool bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Gap.customGapHeight(70),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.text_patientPortal.tr(),
              style: TypographyTheme.heading1LargeBold.toPrimary
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 30.sp),
            ),
            authorized
                ? Text(
                    LocaleKeys.text_selectOneProfileBelowToSeeDetails.tr(),
                    style: TypographyTheme.textSRegular.toPrimary,
                  )
                : const SizedBox(),
          ],
        ),
        bottomPadding ? Gap.customGapHeight(110) : const SizedBox(),
      ],
    );
  }
}
