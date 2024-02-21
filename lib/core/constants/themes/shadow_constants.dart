import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

/// [INFO]
/// Constant for shadows to be used in the app with following the design system
class BaseShadow {
  static List<BoxShadow> shadow = [
    BoxShadow(
      color: BaseColor.shadow.withOpacity(0.06),
      offset: const Offset(0, 0.36),
      blurRadius: 0.73,
    ),
    BoxShadow(
      color: BaseColor.shadow.withOpacity(0.1),
      offset: const Offset(0, 0.36),
      blurRadius: 1.09,
    ),
  ];

  static List<BoxShadow> shadowReversed = [
    BoxShadow(
      color: BaseColor.shadow.withOpacity(0.06),
      offset: const Offset(0, -0.36),
      blurRadius: 3,
      spreadRadius: 3,
    ),
    BoxShadow(
      color: BaseColor.shadow.withOpacity(0.1),
      offset: const Offset(0, -0.36),
      blurRadius: 3,
      spreadRadius: 3,
    ),
  ];
}
