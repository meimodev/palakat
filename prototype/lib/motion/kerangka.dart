import 'package:flutter/widgets.dart';

export 'gerak.dart';

/// One Bingkai per board keyframe (motion.md, "Keyframes").
abstract final class Kerangka {
  static Widget muncul(BuildContext c, double t, Curve k, Widget w) {
    final p = k.transform(t);
    return Opacity(opacity: p, child: Transform.translate(offset: Offset(0, 8 * (1 - p)), child: w));
  }

  static Widget masuk(BuildContext c, double t, Curve k, Widget w) {
    final p = k.transform(t);
    return Opacity(opacity: p, child: Transform.translate(offset: Offset(24 * (1 - p), 0), child: w));
  }

  static Widget naik(BuildContext c, double t, Curve k, Widget w) =>
      FractionalTranslation(translation: Offset(0, 1 - k.transform(t)), child: w);

  static Widget pudar(BuildContext c, double t, Curve k, Widget w) => Opacity(opacity: k.transform(t), child: w);
}
