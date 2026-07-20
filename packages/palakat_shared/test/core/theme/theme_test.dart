import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_shared/core/theme/theme.dart';

// ponytail: these pin the three things that fail silently — a wrong font family
// string falls back invisibly, and a missing focus border is only visible to
// keyboard users. Everything else in buildAppTheme() fails loudly.
void main() {
  // buildAppTheme() sizes type with flutter_screenutil's `.sp`, which throws
  // unless ScreenUtil has been configured first.
  setUpAll(() {
    ScreenUtil.configure(
      data: const MediaQueryData(size: Size(390, 844)),
      designSize: const Size(390, 844),
      minTextAdapt: false,
      splitScreenMode: false,
    );
  });

  test('theme applies the packaged OpenSans family', () {
    final theme = buildAppTheme();

    // The `packages/` prefix is required because the font ships from
    // palakat_shared, not from the consuming app. Drop it and Flutter silently
    // renders the platform default.
    expect(kAppFontFamily, 'packages/palakat_shared/OpenSans');
    expect(theme.textTheme.bodyLarge?.fontFamily, kAppFontFamily);
    expect(theme.textTheme.headlineMedium?.fontFamily, kAppFontFamily);
    expect(theme.textTheme.labelLarge?.fontFamily, kAppFontFamily);
  });

  test('focused inputs draw a visible border', () {
    final input = buildAppTheme().inputDecorationTheme;

    final focused = input.focusedBorder as OutlineInputBorder;
    expect(focused.borderSide.width, 2);
    expect(focused.borderSide.color, AppColors.primary);
    expect(focused.borderSide.style, BorderStyle.solid);

    final focusedError = input.focusedErrorBorder as OutlineInputBorder;
    expect(focusedError.borderSide.width, 2);
    expect(focusedError.borderSide.color, AppColors.error);

    // At rest the field stays borderless; that part is deliberate.
    expect(
      (input.enabledBorder as OutlineInputBorder).borderSide,
      BorderSide.none,
    );
  });
}
