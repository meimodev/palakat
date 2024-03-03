import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({
    super.key,
    this.color,
    this.thickness = 2,
    this.axis = Axis.vertical,
    this.height,
    this.width,
  });

  final double thickness;
  final Color? color;
  final Axis? axis;

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? (axis == Axis.vertical ? thickness : null),
      height: height ?? (axis == Axis.horizontal ? thickness : null),
      color: color ?? BaseColor.secondaryText,
    );
  }
}
