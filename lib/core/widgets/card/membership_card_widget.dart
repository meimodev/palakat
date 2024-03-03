import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/extensions/extension.dart';
import 'package:palakat/core/widgets/widgets.dart';

enum MembershipCardWidgetVariant { signed, unsigned }

class MembershipCardWidget extends StatelessWidget {
  const MembershipCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BaseColor.cardBackground1,
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      ),
      height: BaseSize.customHeight(62),
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: BaseSize.h12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            "AAA",
            style: BaseTypography.headlineSmall.toSecondary,
          ),
          Gap.w12,
          const DividerWidget(),
          Gap.w12,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Cong Name",
                  style: BaseTypography.bodyMedium.bold,
                  textAlign: TextAlign.start,
                ),
                Text(
                  "Member Name",
                  style: BaseTypography.bodyMedium,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          Gap.w12,
          const DividerWidget(),
          Gap.w12,
          Text(
            "22",
            style: BaseTypography.headlineSmall.toSecondary,
          ),
        ],
      ),
    );
  }
}
