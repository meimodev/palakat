import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class HospitalCardLayoutWidget extends StatelessWidget {
  const HospitalCardLayoutWidget({
    super.key,
    required this.text,
    this.onTap,
  });

  final String text;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final enable = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BaseSize.radiusLg),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: BaseSize.w16,
          vertical: BaseSize.h24,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: BaseColor.neutral.shade20,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(BaseSize.radiusLg),
        ),
        child: Row(
          children: [
            Assets.icons.line.hospital3.svg(
              width: BaseSize.customWidth(22),
              height: BaseSize.customWidth(22),
              colorFilter: enable
                  ? BaseColor.primary3.filterSrcIn
                  : BaseColor.neutral.shade50.filterSrcIn,
            ),
            Gap.w12,
            Expanded(
              child: Text(
                text,
                style: TypographyTheme.textLSemiBold.fontColor(
                  enable
                      ? BaseColor.neutral.shade80
                      : BaseColor.neutral.shade50,
                ),
              ),
            ),
            Assets.icons.line.chevronRight.svg(
              width: BaseSize.customWidth(22),
              height: BaseSize.customWidth(22),
              colorFilter: enable
                  ? BaseColor.neutral.shade80.filterSrcIn
                  : BaseColor.neutral.shade50.filterSrcIn,
            ),
          ],
        ),
      ),
    );
  }
}
