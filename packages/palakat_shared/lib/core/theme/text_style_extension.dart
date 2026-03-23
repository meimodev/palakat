import 'package:palakat_shared/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension XTextStyle on TextStyle {
  /// [INFO]
  /// Extension for change text color
  TextStyle get toBlack => copyWith(color: AppColors.primary);
  TextStyle get toWhite => copyWith(color: AppColors.surfaceContainerLowest);
  TextStyle get toPrimary => copyWith(color: AppColors.primary);
  TextStyle get toSecondary => copyWith(color: AppColors.onSurfaceVariant);
  TextStyle get toError => copyWith(color: AppColors.error);
  TextStyle get toInfo => copyWith(color: AppColors.primary);
  TextStyle get toWarning => copyWith(color: AppColors.warning);
  TextStyle get toSuccess => copyWith(color: AppColors.success);

  TextStyle get toRed50 => copyWith(color: AppColors.error);
  TextStyle get toRed100 => copyWith(color: AppColors.error);
  TextStyle get toRed200 => copyWith(color: AppColors.error);
  TextStyle get toRed300 => copyWith(color: AppColors.error);
  TextStyle get toRed400 => copyWith(color: AppColors.error);
  TextStyle get toRed500 => copyWith(color: AppColors.error);
  TextStyle get toRed600 => copyWith(color: AppColors.error);
  TextStyle get toRed700 => copyWith(color: AppColors.error);
  TextStyle get toRed800 => copyWith(color: AppColors.error);
  TextStyle get toRed900 => copyWith(color: AppColors.error);

  TextStyle get toBlue50 => copyWith(color: AppColors.primary);
  TextStyle get toBlue100 => copyWith(color: AppColors.primary);
  TextStyle get toBlue200 => copyWith(color: AppColors.primary);
  TextStyle get toBlue300 => copyWith(color: AppColors.primary);
  TextStyle get toBlue400 => copyWith(color: AppColors.primary);
  TextStyle get toBlue500 => copyWith(color: AppColors.primary);
  TextStyle get toBlue600 => copyWith(color: AppColors.primary);
  TextStyle get toBlue700 => copyWith(color: AppColors.primary);
  TextStyle get toBlue800 => copyWith(color: AppColors.primary);
  TextStyle get toBlue900 => copyWith(color: AppColors.primary);

  TextStyle get toYellow50 => copyWith(color: AppColors.warning);
  TextStyle get toYellow100 => copyWith(color: AppColors.warning);
  TextStyle get toYellow200 => copyWith(color: AppColors.warning);
  TextStyle get toYellow300 => copyWith(color: AppColors.warning);
  TextStyle get toYellow400 => copyWith(color: AppColors.warning);
  TextStyle get toYellow500 => copyWith(color: AppColors.warning);
  TextStyle get toYellow600 => copyWith(color: AppColors.warning);
  TextStyle get toYellow700 => copyWith(color: AppColors.warning);
  TextStyle get toYellow800 => copyWith(color: AppColors.warning);
  TextStyle get toYellow900 => copyWith(color: AppColors.warning);

  TextStyle get toGreen50 => copyWith(color: AppColors.success);
  TextStyle get toGreen100 => copyWith(color: AppColors.success);
  TextStyle get toGreen200 => copyWith(color: AppColors.success);
  TextStyle get toGreen300 => copyWith(color: AppColors.success);
  TextStyle get toGreen400 => copyWith(color: AppColors.success);
  TextStyle get toGreen500 => copyWith(color: AppColors.success);
  TextStyle get toGreen600 => copyWith(color: AppColors.success);
  TextStyle get toGreen700 => copyWith(color: AppColors.success);
  TextStyle get toGreen800 => copyWith(color: AppColors.success);
  TextStyle get toGreen900 => copyWith(color: AppColors.success);

  TextStyle get toNeutral0 => copyWith(color: AppColors.neutral);
  TextStyle get toNeutral10 => copyWith(color: AppColors.neutral);
  TextStyle get toNeutral20 => copyWith(color: AppColors.neutral);
  TextStyle get toNeutral30 => copyWith(color: AppColors.neutral);
  TextStyle get toNeutral40 => copyWith(color: AppColors.neutral);
  TextStyle get toNeutral50 => copyWith(color: AppColors.neutral);
  TextStyle get toNeutral60 => copyWith(color: AppColors.neutral);
  TextStyle get toNeutral70 => copyWith(color: AppColors.neutral);
  TextStyle get toNeutral80 => copyWith(color: AppColors.neutral);
  TextStyle get toNeutral90 => copyWith(color: AppColors.neutral);

  TextStyle get toCardBackground1 => copyWith(color: AppColors.surfaceContainerLowest);
  TextStyle get toCardBackground2 => copyWith(color: AppColors.surfaceContainerLowest);

  /// [INFO]
  /// Extension for change font size
  ///
  /// Example:
  /// TypographyTheme.subtitle1.fontSize(20);
  TextStyle fontSizeCustom(double size) => copyWith(fontSize: size.sp);

  /// [INFO]
  /// Extension for change font color
  ///
  /// Example:
  /// TypographyTheme.subtitle1.fontColor(AppColors.primary);
  TextStyle fontColor(Color color) => copyWith(color: color);

  /// [INFO]
  /// Extension for change font weight
  ///
  /// Example:
  /// TypographyTheme.subtitle1.w500;
  TextStyle get w100 => copyWith(fontWeight: FontWeight.w100);
  TextStyle get w200 => copyWith(fontWeight: FontWeight.w200);
  TextStyle get w300 => copyWith(fontWeight: FontWeight.w300);
  TextStyle get w400 => copyWith(fontWeight: FontWeight.w400);
  TextStyle get w500 => copyWith(fontWeight: FontWeight.w500);
  TextStyle get w600 => copyWith(fontWeight: FontWeight.w600);
  TextStyle get w700 => copyWith(fontWeight: FontWeight.w700);
  TextStyle get w800 => copyWith(fontWeight: FontWeight.w800);
  TextStyle get w900 => copyWith(fontWeight: FontWeight.w900);
  TextStyle get toBold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get toRegular => copyWith(fontWeight: FontWeight.w400);

  /// [INFO]
  /// Extension for change font style and decoration
  ///
  /// Example:
  /// TypographyTheme.subtitle1.underline;
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);
  TextStyle get overline => copyWith(decoration: TextDecoration.overline);
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// [INFO]
  /// Extension for change font height and letter spacing
  ///
  /// Example
  /// TypographyTheme.customHeight(2);
  /// or
  /// TypographyTheme.customSpacing(2);
  TextStyle customHeight(double value) => copyWith(height: value.h);
  TextStyle customSpacing(double value) => copyWith(letterSpacing: value.w);

  /// [INFO] Extension for shadow, decorationThicknes and change decorationColor
  TextStyle get underlineWithSpace => underline.copyWith(
    shadows: [const Shadow(color: AppColors.onSurface, offset: Offset(0, -8))],
    decorationThickness: 2,
    color: Colors.transparent,
    decorationColor: AppColors.primary,
  );
}
