import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';

// [INFO]
// Constant for sizes to be used in the app with respecting 8 pixel rules
class BaseSize {
  // [INFO]
  // Sizes that related with width
  static final w2 = 2.0.w;
  static final w4 = 4.0.w;
  static final w8 = 8.0.w;
  static final w10 = 10.0.w;
  static final w12 = 12.0.w;
  static final w14 = 14.0.w;
  static final w16 = 16.0.w;
  static final w18 = 18.0.w;
  static final w20 = 20.0.w;
  static final w22 = 22.0.w;
  static final w24 = 24.0.w;
  static final w28 = 28.0.w;
  static final w32 = 32.0.w;
  static final w36 = 36.0.w;
  static final w40 = 40.0.w;
  static final w44 = 44.0.w;
  static final w48 = 48.0.w;
  static final w52 = 52.0.w;
  static final w56 = 56.0.w;
  static final w64 = 64.0.w;
  static final w72 = 72.0.w;
  static final w80 = 80.0.w;
  static final w84 = 84.0.w;
  static final w96 = 96.0.w;
  static final w6 = 6.0.w;
  static var w3 = 3.0.w;

  // [INFO]
  // Sizes that related with height
  static final h2 = 2.0.h;
  static final h4 = 4.0.h;
  static final h8 = 8.0.h;
  static final h10 = 10.0.h;
  static final h12 = 12.0.h;
  static final h16 = 16.0.h;
  static final h18 = 18.0.h;
  static final h20 = 20.0.h;
  static final h24 = 24.0.h;
  static final h28 = 28.0.h;
  static final h32 = 32.0.h;
  static final h36 = 36.0.h;
  static final h40 = 40.0.h;
  static final h48 = 48.0.h;
  static final h52 = 52.0.h;
  static final h56 = 56.0.h;
  static final h64 = 64.0.h;
  static final h72 = 72.0.h;
  static final h80 = 80.0.h;
  static final h96 = 96.0.h;
  static final h6 = 6.0.h;

  // [INFO]
  // Sizes that related with radius
  static final radiusSm = 6.r;
  static final radiusMd = 12.r;
  static final radiusLg = 24.r;
  static final radiusXl = 32.r;

  /// [INFO]
  /// Sizes for custom width or height outside the 8 pixel rules
  static double customWidth(double value) => value.w;

  static double customHeight(double value) => value.h;

  static double customRadius(double value) => value.r;

  static double customFontSize(double value) => value.sp;
}

/// [INFO]
/// Constant for gaps to be used in the app with respecting 8 pixel rules
class Gap {
  /// [INFO]
  /// Gaps that related with width
  static final w4 = SizedBox(width: 4.0);
  static final w8 = SizedBox(width: 8.0);
  static final w10 = SizedBox(width: 10.0);
  static final w12 = SizedBox(width: 12.0);
  static final w16 = SizedBox(width: 16.0);
  static final w20 = SizedBox(width: 20.0);
  static final w24 = SizedBox(width: 24.0);
  static final w28 = SizedBox(width: 28.0);
  static final w32 = SizedBox(width: 32.0);
  static final w36 = SizedBox(width: 36.0);
  static final w40 = SizedBox(width: 40.0);
  static final w48 = SizedBox(width: 48.0);
  static final w52 = SizedBox(width: 52.0);
  static final w56 = SizedBox(width: 56.0);
  static final w64 = SizedBox(width: 64.0);
  static final w72 = SizedBox(width: 72.0);
  static final w80 = SizedBox(width: 80.0);

  static final w3 = SizedBox(width: 3.0);
  static final w6 = SizedBox(width: 6.0);

  /// [INFO]
  /// Gaps that related with height
  static final h2 = SizedBox(height: 2.0);
  static final h4 = SizedBox(height: 4.0);
  static final h8 = SizedBox(height: 8.0);
  static final h10 = SizedBox(height: 10.0);
  static final h12 = SizedBox(height: 12.0);
  static final h16 = SizedBox(height: 16.0);
  static final h20 = SizedBox(height: 20.0);
  static final h24 = SizedBox(height: 24.0);
  static final h28 = SizedBox(height: 28.0);
  static final h32 = SizedBox(height: 32.0);
  static final h36 = SizedBox(height: 36.0);
  static final h40 = SizedBox(height: 40.0);
  static final h48 = SizedBox(height: 48.0);
  static final h52 = SizedBox(height: 52.0);
  static final h56 = SizedBox(height: 56.0);
  static final h64 = SizedBox(height: 64.0);
  static final h72 = SizedBox(height: 72.0);
  static final h80 = SizedBox(height: 80.0);

  static final h6 = SizedBox(height: 6.0);

  /// [INFO]
  /// Gaps for custom width or height outside the 8 pixel rules
  static SizedBox customGapWidth(double value) => SizedBox(width: value.w);

  static SizedBox customGapHeight(double value) => SizedBox(height: value.h);

  /// [INFO]
  /// to get BuildContext.viewPadding.bottom
  /// used for give the empty space to fill the Bottom Outside SafeArea
  static dynamic bottomPadding(BuildContext context) {
    return customGapHeight(context.bottomPadding);
  }
}

final horizontalScreenPadding = EdgeInsets.symmetric(horizontal: 12.0);
