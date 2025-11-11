import 'package:flutter/material.dart';

extension XColor on Color {
  /// [INFO]
  /// Extension for filtering color
  ColorFilter get filterSrcIn => ColorFilter.mode(this, BlendMode.srcIn);
  ColorFilter get filterSrcOut => ColorFilter.mode(this, BlendMode.srcOut);
}
