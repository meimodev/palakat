import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child, this.leading});

  final Widget child;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.surfaceContainerLowest,
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth > 480
                  ? 440.0
                  : constraints.maxWidth;

              return Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (leading != null) leading!,
                      const Spacer(),
                      child,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
