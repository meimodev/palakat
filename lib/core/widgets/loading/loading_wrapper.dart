import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

class LoadingWrapper extends StatelessWidget {
  const LoadingWrapper({super.key, required this.loading, required this.child});

  final bool loading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: SizedBox(
          height: BaseSize.w16,
          width: BaseSize.w16,
          child: const CircularProgressIndicator(
            color: BaseColor.primary3,
          ),
        ),
      );
    }
    return child;
  }
}
