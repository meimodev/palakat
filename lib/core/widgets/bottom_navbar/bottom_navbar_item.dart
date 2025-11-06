import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_admin/core/extension/extension.dart';

class BottomNavBarItem extends StatelessWidget {
  const BottomNavBarItem({
    super.key,
    required this.onPressed,
    required this.activated,
    required this.icon,
  });

  final bool activated;
  final void Function() onPressed;
  final SvgGenImage icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.all(
        Radius.circular(18),
      ),
      onTap: onPressed,
      child: Container(
        height: BaseSize.customWidth(45),
        width: BaseSize.customWidth(45),
        padding: EdgeInsets.symmetric(
          horizontal: activated ? BaseSize.customWidth(14) : BaseSize.w12,
          vertical: activated ? BaseSize.customWidth(14) : BaseSize.w12,
        ),
        decoration: BoxDecoration(
          boxShadow: activated
              ? const []
              : [
                  BoxShadow(
                    color: BaseColor.black.withValues(alpha: .125),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(10, 10),
                  ),
                ],
          color: activated ? BaseColor.primaryText : BaseColor.cardBackground1,
          shape: BoxShape.circle,
        ),
        child: icon.svg(
          colorFilter:
              (activated ? BaseColor.cardBackground1 : BaseColor.primaryText)
                  .filterSrcIn,
        ),
      ),
    );
  }
}
