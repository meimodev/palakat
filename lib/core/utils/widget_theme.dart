import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/extensions/extension.dart';

class WidgetTheme {
  static Color getCheckboxPrimaryColor(Set<WidgetState> states) {
    const Set<WidgetState> interactiveStates = <WidgetState>{
      WidgetState.pressed,
      WidgetState.hovered,
      WidgetState.focused,
      WidgetState.selected
    };
    if (states.any(interactiveStates.contains)) {
      return BaseColor.primary3;
    }
    return BaseColor.neutral.shade40;
  }

  static Color getRadioPrimaryColor(Set<WidgetState> states) {
    const Set<WidgetState> interactiveStates = <WidgetState>{
      WidgetState.pressed,
      WidgetState.hovered,
      WidgetState.focused,
      WidgetState.selected
    };
    if (states.any(interactiveStates.contains)) {
      return BaseColor.primary3;
    }
    return BaseColor.neutral.shade40;
  }
}
