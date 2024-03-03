import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/extensions/extension.dart';

class ChipsWidget extends StatelessWidget {
  const ChipsWidget({super.key, required this.title, this.icon});

  final String title;
  final SvgGenImage? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w6,
        vertical: BaseSize.w6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            icon!.svg(
              height: BaseSize.w12,
              width: BaseSize.w12,
              colorFilter: BaseColor.secondaryText.filterSrcIn,
            ),
          if (icon != null) Gap.w3,
          Text(title, style: BaseTypography.labelSmall.toBold),
        ],
      ),
    );
  }
}
