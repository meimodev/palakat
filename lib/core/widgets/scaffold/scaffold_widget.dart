import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

class ScaffoldWidget extends StatelessWidget {
  const ScaffoldWidget({
    super.key,
    required this.child,
    this.appBar,
    this.resizeToAvoidBottomInset = false,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.disableSingleChildScrollView = false,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final bool disableSingleChildScrollView ;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: appBar,
        body: Padding(
          padding: EdgeInsets.only(
            left: BaseSize.w12,
            right: BaseSize.w12,
          ),
          child: disableSingleChildScrollView ? child
              :  SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Gap.h48,
                child,
                Gap.h64,
              ],
            ),
          ),
        ),
        backgroundColor: backgroundColor ?? BaseColor.white,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
