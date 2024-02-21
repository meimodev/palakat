import 'package:flutter/material.dart';
import 'package:palakat/core/assets/assets.gen.dart';

enum ScaffoldType { auth, authGradient, normal, accountGradient }

class ScaffoldWidget extends StatelessWidget {
  const ScaffoldWidget({
    super.key,
    this.type = ScaffoldType.normal,
    required this.child,
    this.appBar,
    this.useSafeArea = true,
    this.resizeToAvoidBottomInset = false,
    this.backgroundColor,
  });

  final ScaffoldType type;
  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool useSafeArea;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  Widget _handleBuild(BuildContext context) {
    final childWidget = useSafeArea ? SafeArea(child: child) : child;
    switch (type) {
      case ScaffoldType.authGradient:
        return Stack(
          children: <Widget>[
            Assets.images.authVerifBg.image(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.fill,
            ),
            Scaffold(
              backgroundColor: backgroundColor ?? Colors.transparent,
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
              appBar: appBar,
              body: childWidget,
            ),
          ],
        );
      case ScaffoldType.auth:
        return Stack(
          children: <Widget>[
            Assets.images.authBg.image(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Scaffold(
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
              backgroundColor: backgroundColor ?? Colors.transparent,
              appBar: appBar,
              body: childWidget,
            ),
          ],
        );
      case ScaffoldType.accountGradient:
        return Stack(
          children: <Widget>[
            Assets.images.accountBg.image(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Scaffold(
              backgroundColor: backgroundColor ?? Colors.transparent,
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
              appBar: appBar,
              body: childWidget,
            ),
          ],
        );

      default:
        return Scaffold(
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          appBar: appBar,
          body: childWidget,
          backgroundColor:
              backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _handleBuild(context);
  }
}
