import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/extension.dart';

class ChipsWidget extends StatelessWidget {
  const ChipsWidget({super.key, required this.title, this.icon});

  final String title;
  final SvgGenImage? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w12,
        vertical: BaseSize.h8,
      ),
      decoration: BoxDecoration(
        color: BaseColor.primary4.withValues(alpha: 0.08),
        border: Border.all(
          color: BaseColor.primary4.withValues(alpha: 0.24),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(
          BaseSize.radiusLg,
        ),

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
          Text(title, style: BaseTypography.labelMedium.copyWith(
            color: BaseColor.primary4,
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );

  }
}
