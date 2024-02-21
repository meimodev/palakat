import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palakat/core/assets/fonts.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';

class BaseTheme {

  static ThemeData appTheme = ThemeData(
    scaffoldBackgroundColor: BaseColor.neutral.shade0,
    fontFamily: FontFamily.openSans,
    colorScheme: const ColorScheme.light(
      background: Colors.white,
      primary: BaseColor.primary3,
      secondary: BaseColor.secondary2,
    ),
    primaryColor: BaseColor.primary3,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        systemNavigationBarColor: BaseColor.black,
        statusBarBrightness: Brightness.light,
        statusBarColor: BaseColor.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
  );


}

