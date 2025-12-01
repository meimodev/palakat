import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/widgets/mobile/bottom_navbar_item.dart'
    as shared;

/// App-specific BottomNavBarItem that wraps the shared version
/// and provides convenience for using SvgGenImage icons.
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
    return shared.BottomNavBarItem(
      onPressed: onPressed,
      activated: activated,
      icon: icon.svg(
        colorFilter:
            (activated ? BaseColor.cardBackground1 : BaseColor.primaryText)
                .filterSrcIn,
      ),
    );
  }
}
