import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class EmptyAppointment extends StatelessWidget {
  final String placeholder;

  const EmptyAppointment({
    super.key,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: horizontalPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Assets.icons.fill.calendar.svg(
              width: BaseSize.w64,
              height: BaseSize.w64,
              colorFilter: BaseColor.neutral.shade40.filterSrcIn,
            ),
          ),
          Gap.customGapHeight(10),
          Center(
            child: Text(
              placeholder,
              style: TypographyTheme.heading1SmallRegular.toNeutral50,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
