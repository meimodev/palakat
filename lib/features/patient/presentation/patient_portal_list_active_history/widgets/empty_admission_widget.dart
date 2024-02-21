import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';

class EmptyAdmissionWidget extends StatelessWidget {
  const EmptyAdmissionWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.tint.document1.svg(
            width: BaseSize.customWidth(88),
            height: BaseSize.customWidth(88),
          ),
          Gap.h20,
          Text(text, style: TypographyTheme.textMRegular)
        ],
      ),
    );
  }
}
