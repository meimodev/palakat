import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat_admin/core/extension/build_context_extension.dart';

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
  static final w48 = 48.0.w;
  static final w52 = 52.0.w;
  static final w56 = 56.0.w;
  static final w64 = 64.0.w;
  static final w72 = 72.0.w;
  static final w80 = 80.0.w;
  static final w96 = 96.0.w;
  static final w6 = 6.0.w;
  static var w3 = 3.0.w;


  // [INFO]
  // Sizes that related with height
  static final h4 = 4.0.h;
  static final h8 = 8.0.h;
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
  static final w4 = SizedBox(width: BaseSize.w4);
  static final w8 = SizedBox(width: BaseSize.w8);
  static final w12 = SizedBox(width: BaseSize.w12);
  static final w16 = SizedBox(width: BaseSize.w16);
  static final w20 = SizedBox(width: BaseSize.w20);
  static final w24 = SizedBox(width: BaseSize.w24);
  static final w28 = SizedBox(width: BaseSize.w28);
  static final w32 = SizedBox(width: BaseSize.w32);
  static final w36 = SizedBox(width: BaseSize.w36);
  static final w40 = SizedBox(width: BaseSize.w40);
  static final w48 = SizedBox(width: BaseSize.w48);
  static final w52 = SizedBox(width: BaseSize.w52);
  static final w56 = SizedBox(width: BaseSize.w56);
  static final w64 = SizedBox(width: BaseSize.w64);
  static final w72 = SizedBox(width: BaseSize.w72);
  static final w80 = SizedBox(width: BaseSize.w80);

  static final w3 = SizedBox(width: BaseSize.w3);
  static final w6 = SizedBox(width: BaseSize.w6);


  /// [INFO]
  /// Gaps that related with height
  static final h4 = SizedBox(height: BaseSize.h4);
  static final h8 = SizedBox(height: BaseSize.h8);
  static final h12 = SizedBox(height: BaseSize.h12);
  static final h16 = SizedBox(height: BaseSize.h16);
  static final h20 = SizedBox(height: BaseSize.h20);
  static final h24 = SizedBox(height: BaseSize.h24);
  static final h28 = SizedBox(height: BaseSize.h28);
  static final h32 = SizedBox(height: BaseSize.h32);
  static final h36 = SizedBox(height: BaseSize.h36);
  static final h40 = SizedBox(height: BaseSize.h40);
  static final h48 = SizedBox(height: BaseSize.h48);
  static final h52 = SizedBox(height: BaseSize.h52);
  static final h56 = SizedBox(height: BaseSize.h56);
  static final h64 = SizedBox(height: BaseSize.h64);
  static final h72 = SizedBox(height: BaseSize.h72);
  static final h80 = SizedBox(height: BaseSize.h80);

  static final h6 = SizedBox(height: BaseSize.h6);



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


final horizontalScreenPadding = EdgeInsets.symmetric(
  horizontal: BaseSize.w12,
);
