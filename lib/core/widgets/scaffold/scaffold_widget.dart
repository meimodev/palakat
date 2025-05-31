import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

import '../widgets.dart';

class ScaffoldWidget extends StatelessWidget {
  const ScaffoldWidget({
    super.key,
    required this.child,
    this.appBar,
    this.resizeToAvoidBottomInset = false,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.disableSingleChildScrollView = false,
    this.disablePadding = false,
    this.presistBottomWidget,
    this.loading = false,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final bool disableSingleChildScrollView;
  final bool disablePadding;
  final bool loading;
  final Widget? presistBottomWidget;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: appBar,
        body: loading
            ? const AnimatedSwitcher(
                duration: Duration(microseconds: 400),
                child: LoadingWrapper(
                  loading: true,
                  child: CircularProgressIndicator(),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(
                  left: disablePadding ? 0 : BaseSize.w12,
                  right: disablePadding ? 0 : BaseSize.w12,
                ),
                child: disableSingleChildScrollView
                    ? child
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
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
                          presistBottomWidget ?? const SizedBox(),
                        ],
                      ),
              ),
        backgroundColor: backgroundColor ?? BaseColor.white,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
