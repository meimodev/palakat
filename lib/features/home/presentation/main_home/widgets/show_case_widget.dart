import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:showcaseview/showcaseview.dart';

class ShowCaseView extends StatelessWidget {
  const ShowCaseView({
    Key? key,
    required this.globalKey,
    required this.title,
    required this.description,
    required this.child,
    this.shapeBorder = const CircleBorder(),
  }) : super(key: key);

  final GlobalKey globalKey;
  final String title;
  final String description;
  final Widget child;
  final ShapeBorder shapeBorder;

  @override
  Widget build(BuildContext context) {
    return Showcase(
      key: globalKey,
      title: title,
      titleTextStyle:
          TypographyTheme.textSSemiBold.fontColor(BaseColor.neutral.shade80),
      description: description,
      descTextStyle:
          TypographyTheme.textSRegular.fontColor(BaseColor.neutral.shade50),
      // targetShapeBorder: shapeBorder,
      child: child,
    );
  }
}
