import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class EmptySearchLayoutWidget extends StatelessWidget {
  const EmptySearchLayoutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.line.clearSearch.svg(
            height: BaseSize.h80,
            width: BaseSize.w80,
            colorFilter: BaseColor.neutral.shade40.filterSrcIn,
          ),
          Gap.customGapHeight(10),
          Text(
            LocaleKeys.text_noResultCouldBeFound.tr(),
            style: TypographyTheme.heading1SmallRegular.toNeutral50,
          ),
        ],
      ),
    );
  }
}
