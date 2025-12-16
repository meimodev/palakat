import 'package:flutter/material.dart';

/// Utility class for managing drawer transitions and overlays
class DrawerUtils {
  DrawerUtils._();

  static const _drawerRouteName = '__palakat_side_drawer__';

  /// Show a drawer with slide-in transition from the right
  /// Uses the same pattern as other drawers in the app for consistency
  static void showDrawer({
    required BuildContext context,
    required Widget drawer,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    showGeneralDialog(
      context: context,
      routeSettings: const RouteSettings(name: _drawerRouteName),
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(child: drawer),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: curve)),
          child: child,
        );
      },
    );
  }

  /// Close the currently open drawer
  static void closeDrawer(BuildContext context) {
    if (!context.mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final navigator = Navigator.of(context, rootNavigator: true);
      navigator.popUntil((route) => route.settings.name != _drawerRouteName);
    });
  }
}
