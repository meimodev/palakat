import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class ListItemNotificationCardWidget extends StatelessWidget {
  const ListItemNotificationCardWidget({
    super.key,
    this.title,
    this.subTitle,
    this.time,
    this.iconBackgroundColor,
    this.icon,
    this.isRead = true,
    required this.onTap,
  });

  final String? title;
  final String? subTitle;
  final DateTime? time;
  final Color? iconBackgroundColor;
  final SvgGenImage? icon;
  final void Function() onTap;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return RippleTouch(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: BaseSize.h24,
          horizontal: BaseSize.w20,
        ),
        color: isRead ? BaseColor.white : BaseColor.primary1,
        child: Row(
          children: [
            Center(
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: iconBackgroundColor ?? BaseColor.primary1,
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: BaseSize.customWidth(10),
                  vertical: BaseSize.customWidth(10),
                ),
                child: (icon ?? Assets.icons.fill.notify).svg(
                  width: BaseSize.customWidth(25),
                  height: BaseSize.customWidth(25),
                ),
              ),
            ),
            Gap.customGapWidth(17),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title ?? "",
                          style: TypographyTheme.textLSemiBold.toNeutral80,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time?.hhMmAa ?? "",
                        style: TypographyTheme.textSRegular.toNeutral60,
                      ),
                    ],
                  ),
                  Gap.customGapHeight(10),
                  Text(
                    subTitle ?? "",
                    style: TypographyTheme.textMRegular.toNeutral60,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
