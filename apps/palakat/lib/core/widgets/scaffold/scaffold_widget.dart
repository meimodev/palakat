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
    this.persistBottomWidget,
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
  final Widget? persistBottomWidget;

  @override
  Widget build(BuildContext context) {
    final Widget childWrapper = AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: LoadingWrapper(
        paddingTop: BaseSize.h48,
        paddingBottom: BaseSize.h48,
        loading: loading,
        child: child,
      ),
    );

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: appBar,
        body: Padding(
          padding: EdgeInsets.only(
            left: disablePadding ? 0 : BaseSize.w12,
            right: disablePadding ? 0 : BaseSize.w12,
          ),
          child: disableSingleChildScrollView
              ? Column(
                  children: [
                    Expanded(child: childWrapper),
                    persistBottomWidget ?? const SizedBox(),
                  ],
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [Gap.h48, childWrapper, Gap.h64],
                        ),
                      ),
                    ),
                    persistBottomWidget ?? const SizedBox(),
                  ],
                ),
        ),
        backgroundColor: backgroundColor ?? BaseColor.white,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
