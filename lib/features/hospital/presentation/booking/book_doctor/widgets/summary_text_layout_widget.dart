
import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';


class SummaryTextLayoutWidget extends StatelessWidget {
  const SummaryTextLayoutWidget({super.key,
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TypographyTheme.textLRegular.toNeutral60,
            ),
            Gap.customGapHeight(10),
            Text(
              text,
              style: TypographyTheme.bodyRegular.toNeutral80,
            ),
          ],
        ),
        Gap.h20,
      ],
    );
  }
}
