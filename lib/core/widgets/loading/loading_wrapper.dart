import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

class LoadingWrapper extends StatelessWidget {
  const LoadingWrapper({
    super.key,
    required this.loading,
    required this.child,
    this.paddingTop,
    this.paddingBottom,
  });

  final bool loading;
  final Widget child;

  final double? paddingTop;
  final double? paddingBottom;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Padding(
        padding: EdgeInsets.only(
          top: paddingTop ?? 0,
          bottom: paddingBottom ?? 0,
        ),
        child: Center(
          child: SizedBox(
            height: BaseSize.w16,
            width: BaseSize.w16,
            child: const CircularProgressIndicator(
              color: BaseColor.primary3,
            ),
          ),
        ),
      );
    }
    return child;
  }
}
