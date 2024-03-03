import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/core/constants/constants.dart';

extension XTextStyle on TextStyle {
  /// [INFO]
  /// Extension for change text color
  TextStyle get toBlack => copyWith(color: BaseColor.black);
  TextStyle get toWhite => copyWith(color: BaseColor.white);
  TextStyle get toPrimary => copyWith(color: BaseColor.primary3);
  TextStyle get toSecondary => copyWith(color: BaseColor.secondaryText);
  TextStyle get toError => copyWith(color: BaseColor.error);
  TextStyle get toInfo => copyWith(color: BaseColor.info);
  TextStyle get toWarning => copyWith(color: BaseColor.warning);
  TextStyle get toSuccess => copyWith(color: BaseColor.success);

  TextStyle get toRed50 => copyWith(color: BaseColor.red[50]);
  TextStyle get toRed100 => copyWith(color: BaseColor.red[100]);
  TextStyle get toRed200 => copyWith(color: BaseColor.red[200]);
  TextStyle get toRed300 => copyWith(color: BaseColor.red[300]);
  TextStyle get toRed400 => copyWith(color: BaseColor.red[400]);
  TextStyle get toRed500 => copyWith(color: BaseColor.red[500]);
  TextStyle get toRed600 => copyWith(color: BaseColor.red[600]);
  TextStyle get toRed700 => copyWith(color: BaseColor.red[700]);
  TextStyle get toRed800 => copyWith(color: BaseColor.red[800]);
  TextStyle get toRed900 => copyWith(color: BaseColor.red[900]);

  TextStyle get toBlue50 => copyWith(color: BaseColor.blue[50]);
  TextStyle get toBlue100 => copyWith(color: BaseColor.blue[100]);
  TextStyle get toBlue200 => copyWith(color: BaseColor.blue[200]);
  TextStyle get toBlue300 => copyWith(color: BaseColor.blue[300]);
  TextStyle get toBlue400 => copyWith(color: BaseColor.blue[400]);
  TextStyle get toBlue500 => copyWith(color: BaseColor.blue[500]);
  TextStyle get toBlue600 => copyWith(color: BaseColor.blue[600]);
  TextStyle get toBlue700 => copyWith(color: BaseColor.blue[700]);
  TextStyle get toBlue800 => copyWith(color: BaseColor.blue[800]);
  TextStyle get toBlue900 => copyWith(color: BaseColor.blue[900]);

  TextStyle get toYellow50 => copyWith(color: BaseColor.yellow[50]);
  TextStyle get toYellow100 => copyWith(color: BaseColor.yellow[100]);
  TextStyle get toYellow200 => copyWith(color: BaseColor.yellow[200]);
  TextStyle get toYellow300 => copyWith(color: BaseColor.yellow[300]);
  TextStyle get toYellow400 => copyWith(color: BaseColor.yellow[400]);
  TextStyle get toYellow500 => copyWith(color: BaseColor.yellow[500]);
  TextStyle get toYellow600 => copyWith(color: BaseColor.yellow[600]);
  TextStyle get toYellow700 => copyWith(color: BaseColor.yellow[700]);
  TextStyle get toYellow800 => copyWith(color: BaseColor.yellow[800]);
  TextStyle get toYellow900 => copyWith(color: BaseColor.yellow[900]);

  TextStyle get toGreen50 => copyWith(color: BaseColor.green[50]);
  TextStyle get toGreen100 => copyWith(color: BaseColor.green[100]);
  TextStyle get toGreen200 => copyWith(color: BaseColor.green[200]);
  TextStyle get toGreen300 => copyWith(color: BaseColor.green[300]);
  TextStyle get toGreen400 => copyWith(color: BaseColor.green[400]);
  TextStyle get toGreen500 => copyWith(color: BaseColor.green[500]);
  TextStyle get toGreen600 => copyWith(color: BaseColor.green[600]);
  TextStyle get toGreen700 => copyWith(color: BaseColor.green[700]);
  TextStyle get toGreen800 => copyWith(color: BaseColor.green[800]);
  TextStyle get toGreen900 => copyWith(color: BaseColor.green[900]);

  TextStyle get toNeutral0 => copyWith(color: BaseColor.neutral[0]);
  TextStyle get toNeutral10 => copyWith(color: BaseColor.neutral[10]);
  TextStyle get toNeutral20 => copyWith(color: BaseColor.neutral[20]);
  TextStyle get toNeutral30 => copyWith(color: BaseColor.neutral[30]);
  TextStyle get toNeutral40 => copyWith(color: BaseColor.neutral[40]);
  TextStyle get toNeutral50 => copyWith(color: BaseColor.neutral[50]);
  TextStyle get toNeutral60 => copyWith(color: BaseColor.neutral[60]);
  TextStyle get toNeutral70 => copyWith(color: BaseColor.neutral[70]);
  TextStyle get toNeutral80 => copyWith(color: BaseColor.neutral[80]);
  TextStyle get toNeutral90 => copyWith(color: BaseColor.neutral[90]);

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
  /// TypographyTheme.subtitle1.fontColor(BaseColor.black);
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
        shadows: [
          const Shadow(
            color: Colors.black,
            offset: Offset(0, -8),
          ),
        ],
        decorationThickness: 2,
        color: Colors.transparent,
        decorationColor: BaseColor.black,
      );
}
