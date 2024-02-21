import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class ButtonWithBorderWidget extends StatelessWidget {
  const ButtonWithBorderWidget({
    super.key,
    required this.onTap,
    required this.title,
    required this.icon,
  });

  final void Function() onTap;
  final String title;
  final SvgGenImage icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w16,
          vertical: BaseSize.h24,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BaseSize.radiusMd),
          border: Border.all(
            width: 1,
            color: BaseColor.neutral.shade20,
          ),
        ),
        child: Row(
          children: [
            icon.svg(
              colorFilter: BaseColor.primary3.filterSrcIn,
              height: BaseSize.w24,
              width: BaseSize.w24,
            ),
            Gap.w12,
            Expanded(
              child: Text(
                title,
                style: TypographyTheme.textLSemiBold.toNeutral80,
              ),
            ),
            Assets.icons.line.chevronRight.svg(
              width: BaseSize.w24,
              height: BaseSize.h24,
            ),
          ],
        ),
      ),
    );
  }
}
